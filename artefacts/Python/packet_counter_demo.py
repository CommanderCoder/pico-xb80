
import threading
import time


class Mailbox:
    """
    Shared-memory mailbox using packet counters.

    tx_seq: owned by sender
    ack_seq: owned by receiver

    Empty  => tx_seq == ack_seq
    Full   => tx_seq != ack_seq
    """

    def __init__(self, name):
        self.name = name
        self.data = None
        self.tx_seq = 0
        self.ack_seq = 0


def send(mailbox, value):
    while mailbox.tx_seq != mailbox.ack_seq:
        time.sleep(0)

    mailbox.data = value
    mailbox.tx_seq = (mailbox.tx_seq + 1) & 0xFF


def recv(mailbox):
    while mailbox.tx_seq == mailbox.ack_seq:
        time.sleep(0)

    value = mailbox.data
    mailbox.ack_seq = mailbox.tx_seq
    return value


FAST_TO_SLOW = Mailbox("FAST->SLOW")
SLOW_TO_FAST = Mailbox("SLOW->FAST")

NUM_MESSAGES = 20


def fast_thread():
    for i in range(NUM_MESSAGES):
        msg = f"FAST:{i}"
        send(FAST_TO_SLOW, msg)

        reply = recv(SLOW_TO_FAST)

        print(f"[FAST] sent={msg:<12} received={reply}")
        time.sleep(0.001)  # fast side

    print("[FAST] done")


def slow_thread():
    for i in range(NUM_MESSAGES):
        incoming = recv(FAST_TO_SLOW)

        time.sleep(1.100)  # 100x slower than fast side

        reply = f"ACK:{i}"
        send(SLOW_TO_FAST, reply)

        print(f"[SLOW] received={incoming:<8} replied={reply}")

    print("[SLOW] done")


if __name__ == "__main__":
    t_fast = threading.Thread(target=fast_thread)
    t_slow = threading.Thread(target=slow_thread)

    start = time.perf_counter()

    t_fast.start()
    t_slow.start()

    t_fast.join()
    t_slow.join()

    elapsed = time.perf_counter() - start

    assert FAST_TO_SLOW.tx_seq == FAST_TO_SLOW.ack_seq
    assert SLOW_TO_FAST.tx_seq == SLOW_TO_FAST.ack_seq

    print(f"\\nPASS - all {NUM_MESSAGES} bidirectional exchanges completed")
    print(f"Elapsed time: {elapsed:.2f} seconds")
