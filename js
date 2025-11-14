// В web/index.html
function calculatePrice() {
  const distance = 150; // в км (можно рассчитать через API Яндекс.Карт)
  const base = 300;
  const perKm = 10;
  return base + distance * perKm;
}
