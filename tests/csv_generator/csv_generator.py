import random
from datetime import datetime, timedelta, timezone

n = 100_000_000         # строк
users = 100_000         # уникальных id
days = 365 * 1          # за сколько дней

now = datetime.now(timezone.utc).replace(tzinfo=None)
start = now - timedelta(days=days)
step = timedelta(seconds=days * 86400 / n)

with open("data.csv", "w") as f:
    t = start
    for _ in range(n):
        uid = random.randint(1, users)
        f.write(f"{uid},{t:%Y-%m-%d %H:%M:%S}\n")
        t += step

# data_100 - 100млн всего, 100к уникальных, 1 год
# data_200 - 200млн всего, 60млн уникальных, 3 года
# data_500 - 500млн всего, 450млн уникальных, 5 лет