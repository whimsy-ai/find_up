import 'package:puppeteer/puppeteer.dart';

const _chromePathX86 =
    'C:\\Program Files (x86)\\Google\\Chrome\\Application\\chrome.exe';
const _chromePath =
    'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe';
const _edgePath =
    'C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe';

abstract class Translator {
  static String? proxyServer;
  Browser? _browser;
  Page? _page;

  void setLanguage(String source, String target);

  Future<String?> translate(String txt);

  Future<Page> getPage() async {
    _browser ??= await _getBrowser();
    _page ??= await _browser!.newPage();
    return _page!;
  }

  Future<Browser> _getBrowser() => puppeteer.launch(
        // headless: false,
        // devTools: true,
        noSandboxFlag: true,
        executablePath: _chromePath,
        args: [
          if (proxyServer != null) '--proxy-server=$proxyServer',
        ],
      );

  Future<void> closeBrowser() async {
    await _browser?.close();
    _browser = null;
    _page = null;
  }
}
