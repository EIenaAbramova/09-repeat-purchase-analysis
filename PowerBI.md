# Как перенести расчёты в Power BI

Готовая визуализация — Report.html. Этот файл объясняет перенос в Power BI; готовый PBIX не поставляется.

1. Get Data → Text/CSV → `data/orders_enriched.csv`, UTF-8, разделитель запятая.
2. Установите типы: order_date и previous_order_date — Date, sales — Decimal Number с локалью English (United States), purchase_number и days_since_previous — Whole Number. Пустой интервал первой покупки остаётся null. Удалите автоматический шаг Changed Type, если он неверно распознал десятичную точку.
3. Назовите таблицу Orders. Номер покупки и интервал уже посчитаны по полной истории. При обновлении сначала пересобирайте CSV через src/analyze.py; импорт новых строк без пересчёта нарушит нумерацию.
4. Создайте меры ниже. Если DAX в вашей локали требует `;`, замените разделители аргументов.
5. Scatter chart: Values/Details (название зависит от интерфейса) — purchase_number как категория; X — Average interval; Y — Average check; Size — Average check; Tooltips — Orders count и Median interval. Фильтр уровня визуала purchase_number > 1. Числовое поле purchase_number не должно суммироваться.
6. Столбцы: X purchase_number, Y Orders count, сортировка номера по возрастанию. Для сравнения устойчивости средних можно использовать Orders count и как Size пузырьков.
7. Для года добавьте Year = YEAR(Orders[order_date]), срезы Year, segment, region. История не перенумеровывается. Избегайте вычисления номера покупки мерой на отфильтрованной таблице.
8. Четыре карточки: Orders count, Customers count, Average check, Average interval. Первые заказы считаются в карточках, но не в среднем интервале: AVERAGE игнорирует BLANK.

```dax
Orders count = COUNTROWS(Orders)
Customers count = DISTINCTCOUNT(Orders[customer_id])
Sales amount = SUM(Orders[sales])
Average check = DIVIDE([Sales amount], [Orders count])
Average interval = AVERAGE(Orders[days_since_previous])
Median interval = MEDIAN(Orders[days_since_previous])
Year = YEAR(Orders[order_date])
```

Последняя формула — вычисляемый столбец, остальные — меры. Не используйте COUNT(Quantity) или SUM(Quantity) для числа заказов. В исходном CSV одна строка на заказ; при изменении детализации этот факт нужно проверить заново.

Контроль без фильтров: 5 009 заказов, 793 клиента, 4 216 непустых интервалов, 17 пузырьков в сводке и 16 в диаграмме без первых покупок. Для второго номера: 781 заказ, X 279,0294494, Y 439,6568268. Средний чек всех заказов 458,6146657; средний интервал повторов 188,0018975.
