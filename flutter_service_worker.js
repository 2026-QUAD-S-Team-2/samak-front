'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"version.json": "9ca2c1fd6d9b684464ed93bab6e0255d",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"canvaskit/canvaskit.js": "140ccb7d34d0a55065fbd422b843add6",
"canvaskit/skwasm.js": "1ef3ea3a0fec4569e5d531da25f34095",
"canvaskit/skwasm.wasm": "264db41426307cfc7fa44b95a7772109",
"canvaskit/skwasm.js.symbols": "0088242d10d7e7d6d2649d1fe1bda7c1",
"canvaskit/skwasm_heavy.js": "413f5b2b2d9345f37de148e2544f584f",
"canvaskit/skwasm_heavy.wasm": "8034ad26ba2485dab2fd49bdd786837b",
"canvaskit/chromium/canvaskit.js": "5e27aae346eee469027c80af0751d53d",
"canvaskit/chromium/canvaskit.js.symbols": "193deaca1a1424049326d4a91ad1d88d",
"canvaskit/chromium/canvaskit.wasm": "24c77e750a7fa6d474198905249ff506",
"canvaskit/canvaskit.js.symbols": "58832fbed59e00d2190aa295c4d70360",
"canvaskit/canvaskit.wasm": "07b9f5853202304d3b0749d9306573cc",
"canvaskit/skwasm_heavy.js.symbols": "3c01ec03b5de6d62c34e17014d1decd3",
"logo.png": "25f12caf23df9413fea7968899879d8b",
"flutter.js": "888483df48293866f9f41d3d9274a779",
"flutter_bootstrap.js": "44db0692703787f33e37446aaa06c20d",
"manifest.json": "eb23ba23b951654e9329ff976101c0bf",
"index.html": "51129fe9c71e5c96d84fa935a36fda02",
"/": "51129fe9c71e5c96d84fa935a36fda02",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"main.dart.js": "b9015f96deee3056a63c3fe5047792fa",
"assets/NOTICES": "6b4a6b5567572a26d448cabd33823b52",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/AssetManifest.bin": "3cd97b3a8df64f1eee0e9fb0f3c84706",
"assets/AssetManifest.bin.json": "f533991dc457b7f4a90330b9e244c24a",
"assets/AssetManifest.json": "a171d13303d4ae39cb955721c66fe605",
"assets/FontManifest.json": "23ccacd143a95cd8006dff65bc3b760e",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/fonts/MaterialIcons-Regular.otf": "4c8c2bbbc742aac608ea826d9687c1c5",
"assets/assets/icons/ic_map.svg": "96e4f0520134eb8ee091d1d7c929c701",
"assets/assets/icons/ic_two-line-horizontal.svg": "44a510ec8b10c42ab136e1784a3bc789",
"assets/assets/icons/ic_mobile.svg": "d33ef3890a241f5ade4864a99e532671",
"assets/assets/icons/ic_alert_filled.svg": "02db061f79c6aecb6ce0a6324457be72",
"assets/assets/icons/ic_banner.png": "eafe6c3c188b7b283d0d929fc4052612",
"assets/assets/icons/ic_googleicon.png": "494725227766c39f69692843d6604b60",
"assets/assets/icons/ic_chat-dots_filled.svg": "b98b7105a4340105cd0fe5d0f8085cdf",
"assets/assets/icons/ic_chat-dots.svg": "ce43a872165d1562ac47d7799f549672",
"assets/assets/icons/ic_credit-card.svg": "76c9c8e0a5aa5a71a40063063f94a3f3",
"assets/assets/icons/ic_question-circle.svg": "7bf55c955cccf093575cd54db30f42b1",
"assets/assets/icons/ic_share.svg": "73ac2a2a517ac0c31a17455a099453c3",
"assets/assets/icons/ic_bell.svg": "e0938dd87aafc9013d801eb61260f900",
"assets/assets/icons/ic_arrow-down.svg": "ecd3460db94faaf318d59309fcea1b8d",
"assets/assets/icons/ic_heart.svg": "67ebe9f62df7e9cde586d790d0573275",
"assets/assets/icons/ic_back.svg": "e7c364a221f74550ec32856d2ff2866f",
"assets/assets/icons/ic_add.svg": "66a7cc092b1f0f07993482fff92ca740",
"assets/assets/icons/ic_title2.svg": "a2f69337272c6dde342560166506e1bc",
"assets/assets/icons/ic_settings.svg": "e8161aa440b51efaaa87b43d50d2efa0",
"assets/assets/icons/ic_bad-face.svg": "c981fef9f70320a57dc629e530e9eeaa",
"assets/assets/icons/ic_menu.svg": "70660097fc23010c90810eb9fb11809b",
"assets/assets/icons/ic_eye.svg": "7f7b5cd542c04b74d988f227f5a0a6ee",
"assets/assets/icons/ic_clock.svg": "09b3a94dc240883e1564f1c40f18796f",
"assets/assets/icons/ic_user_filled.svg": "57b58a419ee6224ed8303f11d8edf3c1",
"assets/assets/icons/ic_user.svg": "39c79fa5ee8b573f64205c21321c4b30",
"assets/assets/icons/ic_alert.svg": "fd146d4a48f880abcb30704b414037b8",
"assets/assets/icons/ic_add_filled.svg": "120a05ee44bf91ec67c4a0619a03660a",
"assets/assets/icons/ic_title.svg": "c08651f2fbf0015bae38ef42b9fae314",
"assets/assets/icons/ic_search_type.svg": "071761ae221f402dc58461e8503feeaf",
"assets/assets/icons/ic_settings-line.svg": "a806958426445be07fb635a3f43725ba",
"assets/assets/icons/ic_message-2.svg": "7c208fbf30c44394f49b33568889ad3b",
"assets/assets/icons/ic_appBar_title.svg": "ec05f16b24780a1f8b4323a2d4cd9fbc",
"assets/assets/icons/ic_heart_filled.svg": "fe45c7a1b70a0302d3c67f2d0edac48c",
"assets/assets/icons/ic_normal-face.svg": "a3f016733f1516edcdaa454c253e68e8",
"assets/assets/icons/ic_search.svg": "0f84b874ac6f9d6435d5f96ffbf23c6e",
"assets/assets/icons/logo_image.svg": "10b6f36932a513699ca2a510999f163c",
"assets/assets/icons/ic_home.svg": "754c07e8c276bbfc7d863ce71b75e160",
"assets/assets/icons/ic_mail.svg": "46116cd66a3b7babc6cd240aab31b492",
"assets/assets/icons/ic_default-profile.svg": "d368997418ec79d007eaf83c503e03f9",
"assets/assets/icons/ic_home_filled.svg": "d4e7431b02f653b5c24aa559b2d4eb6a",
"assets/assets/icons/ic_good-face.svg": "cbca92f882a7b04fb5068b79cc22169c",
"assets/assets/icons/ic_protect.svg": "98a0250d8eebe1d531ddad3b364c94e7",
"assets/assets/icons/ic_more.svg": "62d304234ec071d3412936731237dcd0",
"assets/assets/icons/ic_wallet.svg": "8ae4e338f601a3c596770be6677fc7a2",
"assets/assets/images/fraud_guide_4.png": "42574ca5bd487576b639a5d3ff68cdfd",
"assets/assets/images/fraud_guide_6.png": "f2f1fb2571528aaf4bd5149be8f61319",
"assets/assets/images/fraud_guide_2.png": "3437b3be43d97c38244e6fe797596746",
"assets/assets/images/fraud_guide_5.png": "b6e8bd8623b7698302f6a2b0e590dd45",
"assets/assets/images/fraud_guide_3.png": "418623e8b6339d907b5853b151104a15",
"assets/assets/images/fraud_guide_1.png": "42c4c6b4e2a853a35be398bd31ce8acc",
"assets/assets/fonts/Roboto-Regular.ttf": "303c6d9e16168364d3bc5b7f766cfff4",
"assets/assets/fonts/Roboto-Bold.ttf": "dd5415b95e675853c6ccdceba7324ce7",
"assets/assets/fonts/Roboto-Medium.ttf": "7d752fb726f5ece291e2e522fcecf86d"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
