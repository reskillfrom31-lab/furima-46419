const initializeCardForm = () => {
  const form = document.getElementById('charge-form');
  if (!form) {
    return;
  }

  // Payjpまたはgonが未定義の場合、50ミリ秒後に再試行
  if (typeof Payjp === 'undefined' || typeof gon === 'undefined') {
    setTimeout(initializeCardForm, 50);
    return;
  }

  const publicKey = gon.public_key;
  if (!publicKey) {
    console.error('Payjp public key is not set');
    return;
  }

  const payjp = Payjp(publicKey);
  const elements = payjp.elements();

  // カード番号入力フィールドの作成とマウント
  const numberElement = elements.create('cardNumber', {
    style: {
      base: {
        fontSize: '16px',
        color: '#424770',
        '::placeholder': {
          color: '#aab7c4',
        },
      },
    },
  });

  // 有効期限入力フィールドの作成とマウント
  const expiryElement = elements.create('cardExpiry', {
    style: {
      base: {
        fontSize: '16px',
        color: '#424770',
        '::placeholder': {
          color: '#aab7c4',
        },
      },
    },
  });

  // CVC入力フィールドの作成とマウント
  const cvcElement = elements.create('cardCvc', {
    style: {
      base: {
        fontSize: '16px',
        color: '#424770',
        '::placeholder': {
          color: '#aab7c4',
        },
      },
    },
  });

  // 要素をマウント（エラーハンドリング付き）
  try {
    numberElement.mount('#number-form');
    console.log('Card number element mounted successfully');
  } catch (error) {
    console.error('Error mounting card number element:', error);
  }

  try {
    expiryElement.mount('#expiry-form');
    console.log('Card expiry element mounted successfully');
  } catch (error) {
    console.error('Error mounting card expiry element:', error);
  }

  try {
    cvcElement.mount('#cvc-form');
    console.log('Card CVC element mounted successfully');
  } catch (error) {
    console.error('Error mounting card CVC element:', error);
  }

  form.addEventListener("submit", (e) => {
    e.preventDefault();
    const submitButton = document.getElementById("button");
    if (!submitButton) {
      console.error('Submit button not found');
      return;
    }
    
    submitButton.disabled = true;

    payjp.createToken(numberElement).then(function (response) {
      if (response.error) {
        // エラーがあればボタンを有効に戻し、フォーム送信はしない
        console.error('Payjp error:', response.error);
        submitButton.disabled = false;
        alert('カード情報に誤りがあります。確認してください。');
      } else {
        const token = response.id;
        const tokenInput = `<input value="${token}" name='token' type='hidden'>`;
        form.insertAdjacentHTML("beforeend", tokenInput);
        form.submit();
      }
    }).catch(function(error) {
      console.error('Token creation failed:', error);
      submitButton.disabled = false;
      alert('カード情報の処理中にエラーが発生しました。');
    });
  });
};

window.addEventListener("DOMContentLoaded", initializeCardForm);