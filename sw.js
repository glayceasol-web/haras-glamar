// App do CTE GLAMAR: guarda a "casca" do app para abrir rápido. Os dados sempre vêm do Supabase.
const CACHE="glamar-v2";
const SHELL=["/","/index.html","/config.js","/logo.jpg","/icon-192.png","/icon-512.png","/manifest.webmanifest","https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2.45.4/dist/umd/supabase.min.js"];
self.addEventListener("install",e=>{e.waitUntil(caches.open(CACHE).then(c=>c.addAll(SHELL)).catch(()=>{}));self.skipWaiting()});
self.addEventListener("activate",e=>{e.waitUntil(caches.keys().then(ks=>Promise.all(ks.filter(k=>k!==CACHE).map(k=>caches.delete(k)))).then(()=>self.clients.claim()))});
self.addEventListener("fetch",e=>{const u=new URL(e.request.url);
  if(e.request.method!=="GET"||u.hostname.endsWith("supabase.co")||u.pathname.endsWith("cadastros-pendentes.json"))return; // dados: sempre da rede
  // rede primeiro (pega a versão nova); sem internet, usa a cópia guardada
  e.respondWith(fetch(e.request).then(r=>{if(r.ok&&(u.origin===location.origin||u.hostname==="cdn.jsdelivr.net")){const cp=r.clone();caches.open(CACHE).then(c=>c.put(e.request,cp))}return r}).catch(()=>caches.match(e.request).then(m=>m||caches.match("/index.html"))))});
