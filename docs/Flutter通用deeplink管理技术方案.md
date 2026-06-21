### 设计一个包含以下功能的HTML：
显示页面标题（由<title>决定）
显示当前时间（用于缓存测试，每次刷新应该变化）
显示cookie内容（通过JS获取）
按钮：调用FlutterBridge发送消息（测试JS Bridge）
按钮：调用FlutterBridge触发原生Toast
按钮：跳转到内部页面（#section2），测试返回键
链接：跳转到外部URL（如 https://www.example.com），用于测试拦截或系统浏览器
链接：跳转到被拦截URL（如 http://blocked.test），测试拦截
按钮：触发一个无效URL（如 http://error.test），测试错误页
活动图片：点击触发一个deeplink的url，进入商品详情页。
活动图片：点击触发一个deeplink的url，进入商品列表页。
订单按钮：点击触发一个deeplink的url, 进入我的订单模块（需要校验是否登录，已登录才可以进入），
长文本使页面可滚动，测试下拉刷新
模拟慢加载：可在Flutter端设置timeout，或者使用setTimeout延迟加载一个资源，但本地HTML瞬间加载，时间太短。可以嵌入一个图片从外部慢速加载，或使用<img>加载一个延迟的图片。但我们无法控制外部资源。简单起见，提示在Flutter中设置timeout=2000，加载一个远程慢URL来测试超时。


### 调试用 HTML 页面

<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <title>WebView 功能调试</title>
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body { font-family: sans-serif; background: #f5f5f5; padding: 16px; }
    h2 { font-size: 18px; margin: 16px 0 8px; border-left: 4px solid #4CAF50; padding-left: 8px; }
    .section { background: white; border-radius: 8px; padding: 12px; margin-bottom: 16px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); }
    .btn { display: inline-block; padding: 10px 16px; margin: 4px; background: #1976D2; color: white; border: none; border-radius: 4px; font-size: 14px; cursor: pointer; }
    .btn:active { opacity: 0.8; }
    .btn.red { background: #D32F2F; }
    .btn.green { background: #388E3C; }
    .btn.orange { background: #F57C00; }
    .info { font-size: 13px; color: #666; margin: 4px 0; word-break: break-all; }
    .long-content { padding: 20px; background: #FFF9C4; border-radius: 4px; margin: 12px 0; }
    a { color: #1976D2; text-decoration: underline; word-break: break-all; }
    hr { margin: 12px 0; border: 0.5px solid #e0e0e0; }
  </style>
</head>
<body>

  <!-- 页面基础信息 -->
  <div class="section">
    <h2>📄 页面信息</h2>
    <div class="info">当前标题：<b id="pageTitle">加载中...</b></div>
    <div class="info">当前时间：<span id="currentTime"></span>（用于验证缓存刷新）</div>
    <div class="info">Cookie 内容：<b id="cookieDisplay"></b></div>
    <div class="info">滚动位置：<span id="scrollY">0</span>px</div>
    <button class="btn" onclick="updateInfo()">刷新信息</button>
  </div>

  <!-- JavaScript Bridge 测试 -->
  <div class="section">
    <h2>🔗 JavaScript Bridge（H5 → Flutter）</h2>
    <p class="info">点击按钮发送消息到 Flutter，观察 Flutter 侧 SnackBar / 日志</p>
    <button class="btn" onclick="sendBridge('hello')">发送 "hello"</button>
    <button class="btn" onclick="sendBridge('pay')">发送支付事件</button>
    <button class="btn green" onclick="sendBridge('close')">发送关闭页面</button>
    <button class="btn orange" onclick="sendBridge('custom', JSON.stringify({action:'share', title:'调试分享'}))">发送自定义JSON</button>
    <br>
    <button class="btn" onclick="requestFlutterAction()">请求 Flutter 执行代码（Flutter→H5）</button>
    <div id="flutterResponse" class="info" style="color:#388E3C; margin-top:8px;"></div>
  </div>

  <!-- 导航与拦截测试 -->
  <div class="section">
    <h2>🧭 导航与拦截</h2>
    <p class="info">点击以下链接或按钮，测试 URL 拦截、系统浏览器跳转、返回键行为</p>
    <a href="https://www.example.com" target="_self">普通外链（example.com）</a><br>
    <a href="https://payment.example.com/pay" target="_self">模拟支付链接（应触发系统浏览器）</a><br>
    <a href="http://blocked.test" target="_self">被拦截URL（应被阻止加载）</a><br>
    <a href="#section2" target="_self">页面内锚点（测试返回键）</a><br>
    <button class="btn" onclick="location.href='https://www.google.com'">跳转 Google（测试拦截/浏览器）</button>
    <button class="btn red" onclick="location.href='http://error.test'">跳转错误URL（测试错误页）</button>
    <hr>
    <p class="info">点击内部链接后，按系统返回键应回退到本页（而非直接关闭）</p>
  </div>

  <!-- 页面滚动测试 -->
  <div class="section">
    <h2>📜 滚动与下拉刷新</h2>
    <div class="long-content">
      <p>向下滚动以测试下拉刷新（需开启 pullToRefresh）</p>
      <p style="height: 600px; background: linear-gradient(#FFF9C4, #FFE082); display: flex; align-items: center; justify-content: center; color: #666;">
        长内容区域——滚动到顶部后可下拉触发刷新
      </p>
    </div>
  </div>

  <!-- 加载性能测试 -->
  <div class="section">
    <h2>⏳ 加载状态 & 超时</h2>
    <p class="info">可通过加载慢速资源或设置短超时来测试：Flutter 端可配置 timeout=2000，并加载一个需要 5 秒响应的 URL</p>
    <button class="btn orange" onclick="simulateSlowLoad()">模拟慢加载（图片延迟）</button>
    <img id="slowImg" style="display:none; width:1px; height:1px;">
  </div>

  <!-- 页脚 -->
  <div id="section2" class="section" style="background:#E3F2FD;">
    <h2>📍 锚点目标区域</h2>
    <p>如果你是通过内部锚点跳转过来的，按返回键应回退到顶部。</p>
  </div>

  <script>
    // ---------- 基础信息更新 ----------
    function updateInfo() {
      document.getElementById('pageTitle').innerText = document.title;
      document.getElementById('currentTime').innerText = new Date().toLocaleString();
      document.getElementById('cookieDisplay').innerText = document.cookie || '(无 Cookie)';
    }
    updateInfo();

    // 监听滚动，反馈给 Flutter（用于下拉刷新冲突测试）
    window.addEventListener('scroll', function() {
      var y = window.scrollY || document.documentElement.scrollTop;
      document.getElementById('scrollY').innerText = y;
      try {
        if (window.FlutterBridge) {
          FlutterBridge.postMessage(JSON.stringify({event:'scroll', y: y}));
        }
      } catch(e) {}
    });

    // ---------- JS Bridge ----------
    function sendBridge(action, data) {
      data = data || action;
      try {
        if (window.FlutterBridge) {
          FlutterBridge.postMessage(JSON.stringify({action: action, data: data}));
        } else {
          alert('FlutterBridge 未注入');
        }
      } catch(e) {
        alert('Bridge 调用失败: ' + e.message);
      }
    }

    // 请求 Flutter 执行代码
    function requestFlutterAction() {
      // 这里发送一个特殊消息，Flutter 侧监听后执行 evaluateJavaScript 来修改 H5 内容
      try {
        FlutterBridge.postMessage(JSON.stringify({action:'request_eval', msg:'请 Flutter 更新此页面'}));
      } catch(e) {
        alert(e.message);
      }
    }

    // Flutter 调用后执行的回调（暴露给 Flutter 的全局函数）
    window.updateFromFlutter = function(message) {
      document.getElementById('flutterResponse').innerText = '来自 Flutter: ' + message;
    };

    // ---------- 慢加载模拟 ----------
    function simulateSlowLoad() {
      var img = document.getElementById('slowImg');
      img.src = 'https://httpbin.org/delay/3';  // 一个延迟响应的图片，会触发加载状态
      img.style.display = 'block';
      img.onload = function() { alert('慢资源加载完成'); };
    }
  </script>
</body>
</html>
''';