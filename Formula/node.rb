# Официальная сборка Node.js darwin-x64 с nodejs.org (без пересборки).
# Как и официальные бинарники, со встроенными openssl/icu/libuv и npm.
# Обновление: поменять version и sha256 (из https://nodejs.org/dist/vX.Y.Z/SHASUMS256.txt).
class Node < Formula
  desc "Platform built on V8 to build network applications (official darwin-x64 binary)"
  homepage "https://nodejs.org/"
  url "https://nodejs.org/dist/v26.9.0/node-v26.9.0-darwin-x64.tar.gz"
  version "26.9.0"
  sha256 "06b2e742ed9025dc84adc830243b3f731956eac9c321bccd0ede384209af02a8"
  license "MIT"

  livecheck do
    url "https://nodejs.org/dist/index.json"
    regex(/"version":\s*"v?(\d+(?:\.\d+)+)"/i)
  end

  link_overwrite "bin/npm", "bin/npx"

  depends_on arch: :x86_64
  depends_on :macos

  def install
    rm_f %w[CHANGELOG.md README.md]
    prefix.install Dir["*"]

    # npm живёт в libexec, как у Homebrew; в bin временные симлинки до post_install
    (libexec/"lib").mkpath
    mv lib/"node_modules", libexec/"lib/node_modules"
    rm bin/"npm", bin/"npx"
    bin.install_symlink libexec/"lib/node_modules/npm/bin/npm-cli.js" => "npm"
    bin.install_symlink libexec/"lib/node_modules/npm/bin/npx-cli.js" => "npx"
    (libexec/"lib/node_modules/npm/npmrc").write("prefix = #{HOMEBREW_PREFIX}\n")
  end

  # Как в homebrew-core: npm копируется в HOMEBREW_PREFIX/lib/node_modules,
  # чтобы глобальные пакеты переживали обновления node.
  def post_install
    node_modules = HOMEBREW_PREFIX/"lib/node_modules"
    node_modules.mkpath
    rm_r node_modules/"npm" if (node_modules/"npm").exist?
    cp_r libexec/"lib/node_modules/npm", node_modules
    bin.install_symlink node_modules/"npm/bin/npm-cli.js" => "npm"
    bin.install_symlink node_modules/"npm/bin/npx-cli.js" => "npx"
    %w[man1 man5 man7].each do |man|
      (HOMEBREW_PREFIX/"share/man"/man).mkpath
      (HOMEBREW_PREFIX/"share/man"/man).install_symlink Dir[node_modules/"npm/man/#{man}/{npm,npx,package-}*"]
    end
  end

  test do
    (testpath/"test.js").write "console.log('hello');"
    assert_equal "hello", shell_output("#{bin}/node #{testpath}/test.js").strip
    assert_equal "1.234,56", shell_output("#{bin}/node -e 'console.log(new Intl.NumberFormat(\"de-DE\").format(1234.56))'").strip
  end
end
