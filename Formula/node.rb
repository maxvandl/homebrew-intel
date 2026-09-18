# Готовый x86_64 Node.js, кросс-собранный нативно на Apple Silicon скриптом
# scripts/build-node-x86_64.sh. В отличие от формулы homebrew-core,
# собран со встроенными зависимостями (openssl, icu, libuv, ...), как
# официальные бинарники nodejs.org, поэтому не тянет 18 x86_64-библиотек.
class Node < Formula
  desc "Platform built on V8 to build network applications (prebuilt x86_64 keg)"
  homepage "https://nodejs.org/"
  url "https://github.com/maxvandl/homebrew-intel/releases/download/node-26.8.2/node-26.8.2-x86_64-macos.tar.gz"
  version "26.8.2"
  sha256 "1cf8a925f233893b35ec98e718a8d1c912c175302cc408daaec84edfdb53c161"
  license "MIT"

  link_overwrite "bin/npm", "bin/npx"

  depends_on arch: :x86_64
  depends_on :macos

  def install
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
