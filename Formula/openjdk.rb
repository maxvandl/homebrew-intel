# OpenJDK 27 для macOS x86_64 из официальной сборки Azul Zulu (TCK-сертифицированный
# OpenJDK, без пересборки). Oracle с JDK 27 публикует macOS-сборки только для aarch64,
# Temurin 27 ещё нет, а сборка из исходников на macOS требует полный Xcode.
# Раскладка как у формулы openjdk в homebrew-core: libexec/openjdk.jdk + симлинки.
class Openjdk < Formula
  desc "Development kit for the Java programming language (Zulu OpenJDK x86_64 build)"
  homepage "https://openjdk.org/"
  url "https://cdn.azul.com/zulu/bin/zulu27.28.101-ca-jdk27.0.0-macosx_x64.tar.gz"
  version "27"
  sha256 "b5d64393a228ad8680e5936cb114243118d3f6d87b668f0280ef8c15d674439c"
  license "GPL-2.0-only" => { with: "Classpath-exception-2.0" }

  livecheck do
    url "https://api.azul.com/metadata/v1/zulu/packages/?java_version=27&os=macos&arch=x64&archive_type=tar.gz&java_package_type=jdk&javafx_bundled=false&latest=true&release_status=ga"
    regex(/"java_version":\s*\[(\d+),\s*(\d+),\s*(\d+)\]/i)
    strategy :page_match do |page, regex|
      page.scan(regex).map { |m| m.join(".") }
    end
  end

  keg_only :shadowed_by_macos

  depends_on arch: :x86_64
  depends_on :macos

  def install
    jdk = libexec/"openjdk.jdk"
    jdk.install "Contents"
    home = jdk/"Contents/Home"
    bin.install_symlink Dir[home/"bin/*"]
    include.install_symlink Dir[home/"include/*.h"]
    include.install_symlink Dir[home/"include/darwin/*.h"]
    man1.install_symlink Dir[home/"man/man1/*"]
  end

  def caveats
    <<~EOS
      For the system Java wrappers to find this JDK, symlink it with
        sudo ln -sfn #{opt_libexec}/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk.jdk
    EOS
  end

  test do
    (testpath/"HelloWorld.java").write <<~JAVA
      class HelloWorld { public static void main(String[] a) { System.out.println("Hello, world!"); } }
    JAVA
    system bin/"javac", "HelloWorld.java"
    assert_match "Hello, world!", shell_output("#{bin}/java HelloWorld")
  end
end
