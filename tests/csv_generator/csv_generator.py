import random, sys
from datetime import datetime, timedelta, timezone

n = int(sys.argv[1])                # количество строк
users = int(sys.argv[2])            # количество уникальных юзеров
hours = 6.0                         # окно в часах
mu, sigma = hours / 2, hours / 6    # нормальное распределение внутри окна

now = datetime.now(timezone.utc).replace(tzinfo=None)
with open("data.csv", "w") as f:
    for _ in range(n):
        uid = random.randint(1, users)
        # обрезаем хвосты до [0, hours]
        sec = min(max(random.gauss(mu, sigma), 0), hours) * 3600
        ts = now - timedelta(seconds=sec)
        f.write(f"{uid},{ts:%Y-%m-%d %H:%M:%S}\n")