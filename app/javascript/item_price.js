const price = () => {
  //変数設定
  const priceInput = document.getElementById("item-price");
  const taxDom = document.getElementById("add-tax-price");
  const profitDom = document.getElementById("profit");

  //入力するたびに表示が変わる様にする
  priceInput.addEventListener("input", () => {
    const inputValue = priceInput.value;
    const priceValue = parseInt(inputValue);
    
    const taxValue = Math.floor(priceValue * 0.1);
    const profitValue = priceValue + taxValue;

    const outputTax = taxValue.toLocaleString();
    const outputProfit = profitValue.toLocaleString();

    taxDom.innerHTML=outputTax;
    profitDom.innerHTML=outputProfit;

    console.log(outputTax);
    console.log(outputProfit);
  })
}

window.addEventListener("turbo:load", price);
window.addEventListener("turbo:render", price);