export async function onRequest(context) {
  const res = await context.next();
  const contentType = res.headers.get("content-type") || "";

  if (contentType.includes("text/html")) {
    let text = await res.text();
    text = text.replace(
      "</body>",
      `<a href="/" style="
        position:fixed;top:20px;right:20px;
        background:linear-gradient(135deg, #7aa2ff, #9b7aff);
        color:#fff;padding:10px 18px;border-radius:999px;
        font-weight:700;text-decoration:none;
        box-shadow:0 6px 18px rgba(123,162,255,0.5);
        z-index:9999;transition:all .25s ease;
      " onmouseover="this.style.transform='scale(1.08)';"
        onmouseout="this.style.transform='scale(1)';">🏠 Home</a></body>`
    );
    return new Response(text, { status: res.status, headers: res.headers });
  }

  return res;
}
