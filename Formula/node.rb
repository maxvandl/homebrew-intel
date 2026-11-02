# Официальная сборка Node.js darwin-x64 с nodejs.org (без пересборки).
# Как и официальные бинарники, со встроенными openssl/icu/libuv и npm.
# Обновление: поменять version и sha256 (из https://nodejs.org/dist/vX.Y.Z/SHASUMS256.txt).
class Node < Formula
  desc "Platform built on V8 to build network applications (official darwin-x64 binary)"
  homepage "https://nodejs.org/"
  url "https://nodejs.org/dist/v26.13.0/node-v26.13.0-darwin-x64.tar.gz"
  version "26.13.0"
  sha256 "525c9b29bb0263d687de60a4cec0e2a6db876a8eb032369e5795eca71e7c358e"
  license "MIT"

  livecheck do
    url "https://nodejs.org/dist/index.json"
    regex(/"version":\s*"v?(\d+(?:\.\d+)+)"/i)
  end

  depends_on arch: :x86_64
  depends_on :macos

  link_overwrite "bin/npm", "bin/npx"

  def install
    rm %w[CHANGELOG.md README.md]
    prefix.install Dir["*"]

    # npm живёт в libexec, как у Homebrew; в bin временные симлинки до post_install_steps
    (libexec/"lib").mkpath
    mv lib/"node_modules", libexec/"lib/node_modules"
    rm bin/"npm", bin/"npx"
    bin.install_symlink libexec/"lib/node_modules/npm/bin/npm-cli.js" => "npm"
    bin.install_symlink libexec/"lib/node_modules/npm/bin/npx-cli.js" => "npx"
    (libexec/"lib/node_modules/npm/npmrc").write("prefix = #{HOMEBREW_PREFIX}\n")
  end

  # Как в homebrew-core: npm копируется в HOMEBREW_PREFIX/lib/node_modules,
  # чтобы глобальные пакеты переживали обновления node.
  post_install_steps do
    remove "lib/node_modules/npm", base: :homebrew_prefix, recursive: true
    copy "libexec/lib/node_modules/npm", "lib/node_modules/npm", target_base: :homebrew_prefix, recursive: true
    symlink "lib/node_modules/npm/bin/npm-cli.js", "bin/npm", source_base: :homebrew_prefix, overwrite: true
    symlink "lib/node_modules/npm/bin/npx-cli.js", "bin/npx", source_base: :homebrew_prefix, overwrite: true
    symlink "lib/node_modules/npm/man/man1/{npm,npx,package-}*", "share/man/man1",
            source_base: :homebrew_prefix, target_base: :homebrew_prefix, source_glob: true, overwrite: true
    symlink "lib/node_modules/npm/man/man5/{npm,npx,package-}*", "share/man/man5",
            source_base: :homebrew_prefix, target_base: :homebrew_prefix, source_glob: true, overwrite: true
    symlink "lib/node_modules/npm/man/man7/{npm,npx,package-}*", "share/man/man7",
            source_base: :homebrew_prefix, target_base: :homebrew_prefix, source_glob: true, overwrite: true
  end

  test do
    (testpath/"test.js").write "console.log('hello');"
    assert_equal "hello", shell_output("#{bin}/node #{testpath}/test.js").strip
    intl = "console.log(new Intl.NumberFormat(\"de-DE\").format(1234.56))"
    assert_equal "1.234,56", shell_output("#{bin}/node -e '#{intl}'").strip
  end
end
