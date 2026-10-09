// Amazon extractors for the Claude in Chrome javascript_tool (run inside browser_batch, ≤5 pages per batch).
// Both return compact pipe-delimited text so results fit the tool's output limit.

// 1. Search results page (https://www.amazon.com/s?k=<kw>&i=stripbooks|digital-text&s=exact-aware-popularity-rank)
//    One line per organic result: ASIN | title | pub date | rating★reviews | prices
//    Note: Amazon abbreviates review counts ("49.8K"); the regex keeps the K.
(document.querySelector('[data-component-type="s-result-info-bar"]')?.innerText.match(/of ([\d,]+|over [\d,]+) results/)||['?'])[0]+'\n'+
[...document.querySelectorAll('div[data-component-type="s-search-result"]')]
  .filter(d=>!d.querySelector('.puis-sponsored-label-text,.s-sponsored-label-text'))
  .slice(0,10)
  .map(d=>{
    const t=d.querySelector('h2')?.innerText.trim().slice(0,48);
    const a=d.getAttribute('data-asin');
    const x=d.innerText;
    const m=(x.match(/[A-Z][a-z]{2}\.? \d{1,2},? \d{4}/)||[''])[0];
    const rv=x.match(/(\d\.\d) out of 5 stars\s*\(?([\d,.]+K?)/);
    const p=[...d.querySelectorAll('.a-price .a-offscreen')].map(x=>x.innerText.replace('CAD ','')).slice(0,2).join('/');
    return `${a}|${t}|${m}|${rv?rv[1]+'★'+rv[2]:'0rv'}|${p}`;
  }).join('\n');

// 2. Product page (https://www.amazon.com/dp/<ASIN>) — scroll first so the details block renders.
//    Returns: title | reviews | publisher | pub date | pages | price | BSR line (or "noBSR" = never sold)
window.scrollTo(0,document.body.scrollHeight);
await new Promise(r=>setTimeout(r,1200));
(()=>{
  const b=document.body.innerText;
  const i=b.indexOf('Best Sellers Rank');
  const bsr=i>=0?b.slice(i+18,i+170).replace(/\s+/g,' ').replace(/\(See Top 100 in [^)]*\)/g,'').trim():'noBSR';
  const t=document.getElementById('productTitle')?.innerText.trim().slice(0,30);
  const rv=document.getElementById('acrCustomerReviewText')?.innerText||'0rv';
  const pg=(b.match(/(\d+) pages/)||['',''])[1];
  const pd=(b.match(/Publication date\s*:?\s*([^\n]{0,25})/)||['',''])[1].trim();
  const pub=(b.match(/Publisher\s*:?\s*([^\n]{0,30})/)||['',''])[1].trim();
  const pr=document.querySelector('#tmmSwatches .a-color-price, #kindle-price')?.innerText?.trim();
  return `${t}|${rv}|${pub}|${pd}|${pg}p|${pr}|${bsr}`;
})();

// 3. Reviews page, logged in (https://www.amazon.ca/product-reviews/<ASIN>/?filterByStar=critical&sortBy=recent)
//    amazon.ca shows only the first 10 reviews per filter and ignores pageNumber.
JSON.stringify([...document.querySelectorAll('[data-hook="review"]')].map(r=>({
  s:(r.querySelector('[data-hook="review-star-rating"], [data-hook="cmps-review-star-rating"]')?.innerText||'').slice(0,3),
  d:(r.querySelector('[data-hook="review-date"]')?.innerText||'').replace(/^Reviewed in .*? on /,''),
  t:(r.querySelector('[data-hook="review-title"]')?.innerText||'').replace(/^\d\.\d out of 5 stars\s*/,'').slice(0,80),
  b:(r.querySelector('[data-hook="review-body"]')?.innerText||'').replace(/\s+/g,' ').slice(0,450)
})));

// 4. Reddit thread page in Playwright (www.reddit.com/r/<sub>/comments/<id>/...): post + top-level comments with scores.
(()=>{
  const post=document.querySelector('shreddit-post');
  const cs=[...document.querySelectorAll('shreddit-comment')].filter(c=>c.getAttribute('depth')==='0').slice(0,8)
    .map(c=>'['+c.getAttribute('score')+'] '+(c.querySelector('[slot="comment"]')?.innerText||'').slice(0,350).replace(/\s+/g,' '));
  return JSON.stringify({url:location.href,title:post?.getAttribute('post-title'),score:post?.getAttribute('score'),
    n:post?.getAttribute('comment-count'),created:post?.getAttribute('created-timestamp'),
    body:(document.querySelector('shreddit-post [slot="text-body"]')?.innerText||'').slice(0,900).replace(/\s+/g,' '),comments:cs});
})();
