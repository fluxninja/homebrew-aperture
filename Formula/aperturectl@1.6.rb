class AperturectlAT16 < Formula
  desc "CLI for flow control and reliability management for modern web applications"
  homepage "https://www.fluxninja.com"
  url "https://github.com/fluxninja/aperture/archive/v1.6.0.tar.gz"
  sha256 "c77354abd1f43978ae732cdcbde351495179325856d693fa3233dbd5958cc373"
  license "Apache-2.0"
  head "https://github.com/fluxninja/aperture.git", branch: "stable/v1.6.x"

  keg_only :versioned_formula

  depends_on "go" => :build

  def install
    git_branch="stable/v1.6.x"
    git_commit_hash="e10143943f1d0d4dff34f8611a580516e4d57c9d"

    require "open3"
    if build.head?
      head_branch="stable/v1.6.x"
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
