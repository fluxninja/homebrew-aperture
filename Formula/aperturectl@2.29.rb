class AperturectlAT229 < Formula
  desc "CLI for flow control and reliability management for modern web applications"
  homepage "https://www.fluxninja.com"
  url "https://github.com/fluxninja/aperture/archive/refs/tags/v2.29.4.tar.gz"
  sha256 "27629dfe674aba58b94ca2aa7337e8b9ed9d2c2057d8ea96ce00111ce661ea92"
  license "Apache-2.0"
  head "https://github.com/fluxninja/aperture.git", branch: "main"

  bottle do
    root_url "https://github.com/fluxninja/homebrew-aperture/releases/download/aperturectl@2.29-2.29.4-rc.1"
    sha256 cellar: :any_skip_relocation, monterey:     "dd6c6926bc1c0455f5848f2e281f65f119dfe0a453985b61ca08d46dd09a5163"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "407f147b1e8dd8885c9ac5ef58e982f3f1e8bb6da8403f19d9e22c1951b87e9c"
  end

  keg_only :versioned_formula

  depends_on "go" => :build

  def install
    git_branch="stable/v2.29.x"
    git_commit_hash="e506d1b1935e309b9305e3bc8e9ae0fc6a382264"

    require "open3"
    if build.head?
      head_branch="stable/v2.29.x"
      stdout, status = Open3.capture2("git", "log", "-n1", "--format=%H")
      odie "Unable to get commit hash for head build" if status != 0
      git_commit_hash=stdout
      git_branch=head_branch
    end

    ENV["APERTURECTL_BUILD_VERSION"]=version
    ENV["APERTURECTL_BUILD_GIT_BRANCH"]=git_branch
    ENV["APERTURECTL_BUILD_GIT_COMMIT_HASH"]=git_commit_hash

    stdout, status = Open3.capture2("./scripts/build_aperturectl.sh", buildpath/"cmd/aperturectl")
    odie "Failed to build aperturectl" if status != 0

    # Move the binary into the final location
    makedirs bin
    mv stdout, bin/"aperturectl"

    generate_completions_from_executable(bin/"aperturectl", "completion")
  end

  test do
    assert_match "aperturectl version #{version}", shell_output("#{bin}/aperturectl --version")
  end
end
