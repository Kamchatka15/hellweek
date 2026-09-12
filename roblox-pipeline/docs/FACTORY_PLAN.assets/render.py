import asyncio, os
from playwright.async_api import async_playwright
HERE = os.path.dirname(os.path.abspath(__file__))
async def main():
    async with async_playwright() as p:
        b = await p.chromium.launch()
        pg = await b.new_page()
        await pg.goto("file://" + os.path.join(HERE, "../FACTORY_PLAN.html"), wait_until="load")
        await pg.evaluate("document.fonts.ready")
        await pg.pdf(
            path=os.path.join(HERE, "..", "..", "..", "The-Game-Factory.pdf"),
            format="Letter", print_background=True, prefer_css_page_size=True,
            display_header_footer=True,
            header_template='<div style="width:100%;font-family:JetBrains Mono,monospace;font-size:7px;color:#78879A;padding:0 0.75in;display:flex;justify-content:space-between;"><span>THE GAME FACTORY · BUSINESS PLAN &amp; TECHNICAL ARCHITECTURE</span><span>ROBLOX BUSINESS · v1.0</span></div>',
            footer_template='<div style="width:100%;font-family:JetBrains Mono,monospace;font-size:7px;color:#78879A;padding:0 0.75in;display:flex;justify-content:space-between;"><span>12 SEP 2026 · governed by ROBLOX_SUCCESS_LOGIC.md</span><span class="pageNumber"></span></div>',
            margin={"top":"0.8in","bottom":"0.9in","left":"0.75in","right":"0.75in"},
        )
        await b.close()
asyncio.run(main())
