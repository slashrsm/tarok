function logURL(requestDetails) {
   console.log("Redirecting: " + requestDetails.url);
   return {redirectUrl: "http://localhost:4000/js/valat.js"};
}

browser.webRequest.onBeforeRequest.addListener(
  logURL,
  {urls: ["https://valat.si/assets/*-client-opt.js"]},
  ["blocking"]
);
