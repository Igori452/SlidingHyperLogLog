import sys
import random
from datetime import datetime, timedelta, timezone

# Значения по умолчанию (data_100)
n = 100_000_000         
users = 100_000         
days = 365 * 1          
output_path = "data.csv"

# Если аргументы переданы из консоли, используем их
if len(sys.argv) >= 5:
    n = int(sys.argv[1])
    users = int(sys.argv[2])
    days = int(sys.argv[3])
    output_path = sys.argv[4]

print(f"Генерация датасета: строк={n}, уникальных={users}, дней={days} -> {output_path}")

now = datetime.now(timezone.utc).replace(tzinfo=None)
start = now - timedelta(days=days)
step = timedelta(seconds=days * 86400 / n)

with open(output_path, "w") as f:
    t = start
    for i in range(n):
        uid = random.randint(1, users)
        f.write(f"{uid},{t:%Y-%m-%d %H:%M:%S}\n")
        t += step
        
        if (i + 1) % 10_000_000 == 0:
            print(f"Сгенерировано {i + 1} строк...")

print("Генерация успешно завершена!")


# data_100 - 100млн всего, 100к уникальных, 1 год
# data_200 - 200млн всего, 60млн уникальных, 3 года
# data_500 - 500млн всего, 450млн уникальных, 5 лет