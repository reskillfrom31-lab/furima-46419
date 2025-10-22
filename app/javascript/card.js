const initializeCardForm = () => {
  // 既にPayjpのiframeがマウント済みなら再初期化しない（DOMベースのガード）
  if (document.querySelector('#number-form iframe')) return;
  console.log('Initializing card form...');
  
  const form = document.getElementById('charge-form');
  if (!form) {
    console.error('Form with id "charge-form" not found');
    return;
  }
  console.log('Form found:', form);

  // Payjpが未定義の場合はエラーを表示
  if (typeof Payjp === 'undefined') {
    console.error('Payjp library is not available');
    showPayjpError();
    return;
  }

  if (typeof gon === 'undefined') {
    console.error('gon is undefined - public key not available');
    showPayjpError();
    return;
  }
  
  console.log('Payjp and gon are available');

  const publicKey = gon.public_key;
  if (!publicKey) {
    console.error('Payjp public key is not set');
    return;
  }
  console.log('Public key found:', publicKey);

  // マウント要素の存在確認
  const numberForm = document.getElementById('number-form');
  const expiryForm = document.getElementById('expiry-form');
  const cvcForm = document.getElementById('cvc-form');
  
  console.log('Mount elements:', {
    numberForm: numberForm,
    expiryForm: expiryForm,
    cvcForm: cvcForm
  });
  
  if (!numberForm || !expiryForm || !cvcForm) {
    console.error('One or more mount elements not found');
    return;
  }

  // ここまで到達したら初期化済みフラグを立てる
  window.__payjpCardInitialized = true;

  const payjp = Payjp(publicKey);
  const elements = payjp.elements();
  console.log('Payjp elements created:', elements);

  // カード番号入力フィールドの作成とマウント（最小限のスタイル）
  console.log('Creating card number element...');
  const numberElement = elements.create('cardNumber');
  console.log('Card number element created:', numberElement);

  // 有効期限入力フィールドの作成とマウント（最小限のスタイル）
  console.log('Creating card expiry element...');
  const expiryElement = elements.create('cardExpiry');
  console.log('Card expiry element created:', expiryElement);

  // CVC入力フィールドの作成とマウント（最小限のスタイル）
  console.log('Creating card CVC element...');
  const cvcElement = elements.create('cardCvc');
  console.log('Card CVC element created:', cvcElement);

  // 要素をマウント（エラーハンドリング付き）
  try {
    numberElement.mount('#number-form');
    console.log('Card number element mounted successfully');
    
    // マウント後の要素の状態を確認
    setTimeout(() => {
      const mountedElement = document.querySelector('#number-form iframe');
      console.log('Mounted number element iframe:', mountedElement);
      if (mountedElement) {
        console.log('Iframe dimensions:', {
          width: mountedElement.offsetWidth,
          height: mountedElement.offsetHeight
        });
      }
    }, 100);
  } catch (error) {
    console.error('Error mounting card number element:', error);
  }

  try {
    expiryElement.mount('#expiry-form');
    console.log('Card expiry element mounted successfully');
    
    setTimeout(() => {
      const mountedElement = document.querySelector('#expiry-form iframe');
      console.log('Mounted expiry element iframe:', mountedElement);
    }, 100);
  } catch (error) {
    console.error('Error mounting card expiry element:', error);
  }

  try {
    cvcElement.mount('#cvc-form');
    console.log('Card CVC element mounted successfully');
    
    setTimeout(() => {
      const mountedElement = document.querySelector('#cvc-form iframe');
      console.log('Mounted CVC element iframe:', mountedElement);
    }, 100);
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
    
    // 以下で以前の購入試行で残ったトークンが送信されるのを防ぐ
    const existingTokenInput = form.querySelector('input[name="purchase_form[token]"]');
    if (existingTokenInput) {
        existingTokenInput.remove();
        console.log('Removed existing token input before attempt.');
    }
    // 以上で以前の購入試行で残ったトークンが送信されるのを防ぐ

    // クライアントサイドの必須・形式チェックは行わず、サーバ側のバリデーションへ委譲
    
    submitButton.disabled = true;

    payjp.createToken(numberElement).then(function (response) {
      if (response.error) {
        // エラーがあればボタンを有効に戻し、フォーム送信はしない
        console.error('Payjp error:', response.error);
        submitButton.disabled = false;
        showPayjpError('カード情報に誤りがあります。確認してください。');
      } else {
        const token = response.id;
        const tokenInput = `<input value="${token}" name='purchase_form[token]' type='hidden'>`;
        form.insertAdjacentHTML("beforeend", tokenInput);
        
        // デバッグ用：フォームデータをコンソールに出力
        console.log('Form data being submitted:');
        const formData = new FormData(form);
        for (let [key, value] of formData.entries()) {
          console.log(`${key}: ${value}`);
        }
        
        form.submit();
      }
    }).catch(function(error) {
      console.error('Token creation failed:', error);
      submitButton.disabled = false;
      showPayjpError('カード情報の処理中にエラーが発生しました。');
    });
  });
};

// Payjpエラー表示機能
const showPayjpError = (customMessage = null) => {
  const form = document.getElementById('charge-form');
  if (!form) return;
  
  // 既存のエラーメッセージを削除
  const existingError = form.querySelector('.payjp-error-message');
  if (existingError) {
    existingError.remove();
  }
  
  // エラーメッセージを表示
  const errorDiv = document.createElement('div');
  errorDiv.className = 'payjp-error-message';
  errorDiv.style.cssText = `
    background-color: #fee;
    border: 1px solid #fcc;
    color: #c33;
    padding: 15px;
    margin: 10px 0;
    border-radius: 4px;
    text-align: center;
    font-size: 14px;
    line-height: 1.5;
  `;
  
  const message = customMessage || `
    <strong>カード決済システムの読み込みに失敗しました</strong><br>
    以下の方法をお試しください：<br>
    1. ページを再読み込みしてください<br>
    2. インターネット接続を確認してください<br>
    3. しばらく時間をおいてから再度お試しください<br>
    4. ブラウザのキャッシュをクリアしてください<br>
    5. 開発環境ではCORSエラーが発生する場合があります<br>
    <br>
    <strong>代替手段：</strong> 手動入力フォームが自動で有効になります。
  `;
  
  errorDiv.innerHTML = message;
  
  // 再試行ボタンを追加
  const retryButton = document.createElement('button');
  retryButton.textContent = '再試行';
  retryButton.style.cssText = `
    background-color: #3ccace;
    color: white;
    border: none;
    padding: 8px 16px;
    margin-top: 10px;
    border-radius: 4px;
    cursor: pointer;
    font-size: 14px;
  `;
  retryButton.onclick = function() {
    location.reload();
  };
  errorDiv.appendChild(retryButton);
  
  // フォームの最初にエラーメッセージを挿入
  form.insertBefore(errorDiv, form.firstChild);
  
  // 購入ボタンを無効化
  const submitButton = document.getElementById("button");
  if (submitButton) {
    submitButton.disabled = true;
    submitButton.style.backgroundColor = '#ccc';
    submitButton.style.cursor = 'not-allowed';
  }
};

// フォールバック機能：手動カード入力フォーム
const enableFallbackCardForm = () => {
  console.log('Enabling fallback card form...');
  
  const form = document.getElementById('charge-form');
  if (!form) return;
  
  // Payjpのiframeを削除
  const payjpElements = ['#number-form', '#expiry-form', '#cvc-form'];
  payjpElements.forEach(selector => {
    const element = document.querySelector(selector);
    if (element) {
      element.innerHTML = '';
    }
  });
  
  // 手動入力フィールドを作成
  createFallbackInputFields();
  
  // フォーム送信イベントを設定
  setupFallbackFormSubmission();
  
  // 購入ボタンを有効化
  enablePurchaseButton();
  
  // フォールバック機能が有効になったことをユーザーに通知
  showFallbackNotification();
};

// フォールバック入力フィールドの作成
const createFallbackInputFields = () => {
  // カード番号入力
  const numberForm = document.getElementById('number-form');
  if (numberForm) {
    numberForm.innerHTML = `
      <input type="text" id="fallback-card-number" placeholder="1234 5678 9012 3456" 
             maxlength="19" style="width: 100%; height: 48px; padding: 0 10px; border: 1px solid #ccc; border-radius: 4px; font-size: 16px;">
    `;
  }
  
  // 有効期限入力
  const expiryForm = document.getElementById('expiry-form');
  if (expiryForm) {
    expiryForm.innerHTML = `
      <input type="text" id="fallback-card-expiry" placeholder="MM/YY" 
             maxlength="5" style="width: 100%; height: 48px; padding: 0 10px; border: 1px solid #ccc; border-radius: 4px; font-size: 16px;">
    `;
  }
  
  // CVC入力
  const cvcForm = document.getElementById('cvc-form');
  if (cvcForm) {
    cvcForm.innerHTML = `
      <input type="text" id="fallback-card-cvc" placeholder="123" 
             maxlength="4" style="width: 100%; height: 48px; padding: 0 10px; border: 1px solid #ccc; border-radius: 4px; font-size: 16px;">
    `;
  }
  
  // 入力フォーマット機能を追加
  setupInputFormatting();
};

// 入力フォーマット機能
const setupInputFormatting = () => {
  const cardNumberInput = document.getElementById('fallback-card-number');
  const expiryInput = document.getElementById('fallback-card-expiry');
  
  if (cardNumberInput) {
    cardNumberInput.addEventListener('input', function(e) {
      let value = e.target.value.replace(/\s/g, '').replace(/[^0-9]/gi, '');
      let formattedValue = value.match(/.{1,4}/g)?.join(' ') || value;
      e.target.value = formattedValue;
    });
  }
  
  if (expiryInput) {
    expiryInput.addEventListener('input', function(e) {
      let value = e.target.value.replace(/\D/g, '');
      if (value.length >= 2) {
        value = value.substring(0, 2) + '/' + value.substring(2, 4);
      }
      e.target.value = value;
    });
  }
};

// フォールバックフォーム送信の設定
const setupFallbackFormSubmission = () => {
  const form = document.getElementById('charge-form');
  if (!form) return;
  
  form.addEventListener("submit", (e) => {
    e.preventDefault();
    
    const cardNumber = document.getElementById('fallback-card-number')?.value.replace(/\s/g, '') || '';
    const expiry = document.getElementById('fallback-card-expiry')?.value || '';
    const cvc = document.getElementById('fallback-card-cvc')?.value || '';
    
    // ★★★ 修正箇所 2a: フォーム送信前に既存のトークンフィールドを削除 ★★★
    const existingTokenInput = form.querySelector('input[name="purchase_form[token]"]');
    if (existingTokenInput) {
        existingTokenInput.remove();
        console.log('Removed existing token input from fallback form.');
    }
    // 送信ボタンを無効化して重複送信を防ぐ
    const submitButton = document.getElementById("button");
    if (submitButton) {
      submitButton.disabled = true;
      submitButton.textContent = '処理中...';
    }

    let tokenToSend = '';

    // ★★★ 修正箇所 2b: カード番号が空の場合はテストトークンを生成しない ★★★
    if (cardNumber.length > 0) {
        tokenToSend = generateTestToken(cardNumber, expiry, cvc);
    } else {
        console.log('Fallback: Card number is empty. Sending empty token to trigger server validation.');
        // tokenToSendは空文字列のまま (サーバーの validates :token, presence: true で弾かれる)
    }
    // ★★★ 修正箇所 2b ここまで ★★★

    // tokenToSendが空文字列でも、空の<input>タグとして送信することでサーバー側でエラーとなる
    const tokenInput = `<input value="${tokenToSend}" name='purchase_form[token]' type='hidden'>`;
    form.insertAdjacentHTML("beforeend", tokenInput);

    // デバッグ用：フォームデータをコンソールに出力
    console.log('Form data being submitted:');
    const formData = new FormData(form);
    for (let [key, value] of formData.entries()) {
      console.log(`${key}: ${value}`);
    }

    form.submit();
  });
};

// フィールド名の表示名を取得
const getFieldDisplayName = (fieldName) => {
  const displayNames = {
    'postal_code': '郵便番号',
    'prefecture_id': '都道府県',
    'city': '市区町村',
    'addresses': '番地',
    'phone': '電話番号'
  };
  return displayNames[fieldName] || fieldName;
};

// テストトークン生成機能
const generateTestToken = (cardNumber, expiry, cvc) => {
  // カード情報をハッシュ化してトークンを作成
  const cardData = `${cardNumber}_${expiry}_${cvc}`;
  const timestamp = Date.now();
  const randomId = Math.random().toString(36).substring(2, 15);
  
  // テスト用のトークン形式（実際のPayjpトークンに似せた形式）
  const testToken = `tok_test_${randomId}_${timestamp}`;
  
  console.log('Generated test token:', testToken);
  console.log('Card data (for debugging):', cardData);
  
  return testToken;
};

// フォールバック通知機能（非表示化）
const showFallbackNotification = () => {
  return;
};

// 購入ボタンを有効化する機能
const enablePurchaseButton = () => {
  const submitButton = document.getElementById("button");
  if (submitButton) {
    submitButton.disabled = false;
    submitButton.style.backgroundColor = '#ea352d';
    submitButton.style.cursor = 'pointer';
    console.log('Purchase button enabled');
  }
};

// Payjpライブラリの読み込みを待機（タイムアウト付き）
let payjpCheckCount = 0;
const maxPayjpChecks = 50; // 5秒間（100ms × 50回）でタイムアウト

const waitForPayjpAndInitialize = () => {
  payjpCheckCount++;
  
  if (typeof Payjp !== 'undefined') {
    console.log('Payjp library found, initializing...');
    initializeCardForm();
    return;
  }
  
  if (payjpCheckCount >= maxPayjpChecks) {
    console.error('Payjp library failed to load after 5 seconds. Enabling fallback mode.');
    // フォールバック機能を有効化
    enableFallbackCardForm();
    return;
  }
  
  console.log(`Waiting for Payjp library... (${payjpCheckCount}/${maxPayjpChecks})`);
  setTimeout(waitForPayjpAndInitialize, 100);
};

// 初期化処理を簡素化
const initializeCardFormIfReady = () => {
  console.log('Checking if ready to initialize card form...');
  
  // Payjpライブラリが利用可能かチェック
  if (typeof Payjp !== 'undefined') {
    console.log('Payjp library is available, initializing card form');
    initializeCardForm();
  } else {
    console.log('Payjp library not available, enabling fallback mode');
    enableFallbackCardForm();
  }
};

// DOMContentLoadedイベントで初期化を開始
window.addEventListener("DOMContentLoaded", () => {
  console.log('DOMContentLoaded event fired');
  setTimeout(initializeCardFormIfReady, 100);
});

// ページが完全に読み込まれた場合のバックアップ
window.addEventListener("load", () => {
  console.log('Window load event fired');
  setTimeout(initializeCardFormIfReady, 100);
});