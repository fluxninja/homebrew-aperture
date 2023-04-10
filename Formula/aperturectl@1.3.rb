class AperturectlAT13 < Formula
  desc "CLI for flow control and reliability management for modern web applications"
  homepage "https://www.fluxninja.com"
  url "https://github.com/fluxninja/aperture/archive/v1.3.0-rc.2.tar.gz"
  sha256 "933d173e6b8d8c52e39666fc97d8da65b11cc860e43994f41b8551a9fccf4ad1"
  license "Apache-2.0"
  head "https://github.com/fluxninja/aperture.git", branch: "stable/v1.3.x"

  keg_only :versioned_formula

  depends_on "go" => :build

  def install
    git_branch="stable/v1.3.x"
    git_commit_hash="b3c45a31a2ff902c49b18f07c70b6b9fa353f9a1"

    require "open3"
    if build.head?
      head_branch="stable/v1.3.x"
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
