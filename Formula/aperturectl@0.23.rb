class AperturectlAT023 < Formula
  desc "CLI for flow control and reliability management for modern web applications"
  homepage "https://www.fluxninja.com"
  url "https://github.com/fluxninja/aperture/archive/v0.23.0-rc.1.tar.gz"
  sha256 "0e82987d909ba55d97b06f807f7b12815d941ad698e19c5164112b172582f386"
  license "Apache-2.0"
  head "https://github.com/fluxninja/aperture.git", branch: "stable/v0.23.x"

  keg_only :versioned_formula

  depends_on "go" => :build

  def install
    ENV["GIT_BRANCH"]="stable/v0.23.x"
    ENV["GIT_COMMIT_HASH"]="193a84844a552fe322b1f5b7705f1ef05d031f26"
    ENV["SOURCE"]="./cmd/aperturectl"
    ENV["TARGET"]=bin/name
    ENV["VERSION"]=version
    ENV["PREFIX"]="aperture"
    ENV["LDFLAGS"]="-s -w"
    if build.head?
      require "open3"
      stdout, status = Open3.capture2("git", "log", "-n1", "--format=%H")
      odie "Unable to get commit hash for head build" if status != 0
      ENV["GIT_COMMIT_HASH"]=stdout
    end

    system "./pkg/info/build.sh"

    generate_completions_from_executable(bin/name, "completion")
  end

  test do
    assert_match "aperturectl version #{version}", shell_output("#{bin}/aperturectl --version")
  end
end
