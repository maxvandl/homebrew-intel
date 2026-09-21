# Готовый x86_64 LLVM 23, кросс-собранный нативно на Apple Silicon
# скриптом scripts/build-llvm23-x86_64.sh. Homebrew больше не публикует
# x86_64-бутылки llvm для macOS, а сборка из исходников под Rosetta
# занимает много часов. Формула просто раскладывает готовый keg.
class LlvmAT23 < Formula
  desc "Next-gen compiler infrastructure (prebuilt x86_64 keg)"
  homepage "https://llvm.org/"
  url "https://github.com/maxvandl/homebrew-intel/releases/download/llvm-23.1.1/llvm-23.1.1-x86_64-macos.tar.gz"
  version "23.1.1"
  sha256 "f6ead706c43df572f0f3ee9a5dc06ba299114be94b07e772ad78c4976c2fd8cb"
  license "Apache-2.0 WITH LLVM-exception"

  keg_only :versioned_formula

  depends_on arch: :x86_64
  depends_on :macos
  depends_on "zstd"

  def clang_config_file_dir
    etc/"clang"
  end

  def install
    prefix.install Dir["*"]

    clang_config_file_dir.mkpath
    touch clang_config_file_dir/".keepme"
    (prefix/"etc").install_symlink clang_config_file_dir

    # Под Rosetta x86_64-шим xcrun не может загрузить libxcrun из arm64-only CLT,
    # поэтому SDK и настоящий линковщик передаём clang явно через конфиг-файлы.
    cfg = <<~CFG
      -isysroot #{MacOS.sdk_path}
      -B#{MacOS::CLT::PKG_PATH}/usr/bin
    CFG
    kernel_major = Utils.safe_popen_read("uname", "-r").split(".").first
    (clang_config_file_dir/"x86_64-apple-darwin.cfg").write cfg
    (clang_config_file_dir/"x86_64-apple-darwin#{kernel_major}.cfg").write cfg
  end

  def caveats
    <<~EOS
      CLANG_CONFIG_FILE_SYSTEM_DIR: #{clang_config_file_dir}
      CLANG_CONFIG_FILE_USER_DIR:   ~/.config/clang
    EOS
  end

  test do
    (testpath/"test.cpp").write "#include <iostream>\nint main(){std::cout<<\"ok\\n\";}\n"
    system bin/"clang++", "test.cpp", "-o", "test"
    assert_equal "ok\n", shell_output("./test")
  end
end
