class AperturectlAT10 < Formula
  desc "CLI for flow control and reliability management for modern web applications"
  homepage "https://www.fluxninja.com"
  url "https://github.com/fluxninja/aperture/archive/v1.0.0.tar.gz"
  sha256 "6bb6f9b64d71221daba779983b64a7f5905e1cddd708190f3b8b65435a8e7bfc"
  license "Apache-2.0"
  head "https://github.com/fluxninja/aperture.git", branch: "stable/v1.0.x"

  keg_only :versioned_formula

  depends_on "go" => :build

  def install
    git_branch="stable/v1.0.x"
    git_commit_hash="7b6653a9381f989755f496723aee46f2bf902d76"

    require "open3"
    if build.head?
      head_branch="stable/v1.0.x"
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
