var CACHE_NAME = 'latihan-pwa-cache-v1';

var urlsToCache = [
    '/',
    '/css/main.css',
    '/js/jquery.min.js',
    '/js/main.js',
    '/images/ugm.png',
    '/fallback.json'
];
self.addEventListener('install', function (event) {
    event.waitUntil(
        caches.open(CACHE_NAME).then(
            function (cache) {
                console.log('service worker do install..',cache);
                return cache.addAll(urlsToCache);
            },
            // function (err) {
            //     console.log('err : ' , err);
            // }
        )
    )
});

// Aktifasi cache
self.addEventListener('activate', function(event) {
    event.waitUntil(
        caches.keys().then(function(cacheNames){
            return Promise.all(
            // delete cache jika ada versi lebih baru
            cacheNames.filter(function(cacheName){
                return cacheName !== CACHE_NAME;
            }).map (function(cacheName){
                return caches.delete(cacheName);
            })
        );
    })
    );
});

// Fetch cache 
self.addEventListener('fetch', function(event){
    var request = event.request;
    var url = new URL (request.url);

    // Memisahkan cache file dgn cache data API
    if (url.origin === location.origin){
        event.respondWith (
            caches.match(request).then(function(response){
                return response || fetch (request);
            })
        )
    } else {
        event.respondWith (
            caches.open('latihan-pwa-cache-v1')
            .then(function(cache){
                return fetch (request).then(function(liveRequest){
                    cache.put(request, liveRequest.clone());
                    return liveRequest;
                }).catch (function(){
                    return caches.match(request)
                    .then(function(response){
                        if(response) return response;
                        return caches.match('/fallback.json');
                    })
                })
            })
        )
    }

    /* event.respondWith(
        caches.match(event.request)
        .then(function(response){
            console.log(response);
            if (response){
                return response;
            }
            return fetch(event.request);
        })
    )*/
})
self.addEventListener('sync', function(event){
    console.log('firing-sync');
    if(event.tag==='image-fetch'){
        console.log('sync event fired');
        event.waitUntil(fetchImage());
    }
});

function fetchImage(){
    console.log('firing:doSomeStuff()');
    fetch('/images/ugm.png').then(function(response){
        return response;
    }).then(function(text){
        console.log('request success',text);
    }).catch(function(err){
        console.log('required failed',err);
    });

}
