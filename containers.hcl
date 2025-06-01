# CLI Reference: https://docs.docker.com/reference/cli/docker/buildx/bake/
# HCL: https://docs.docker.com/build/bake/reference/


# ---------------------------------------------------------
# region :: registry
variable "PUSH" { default = false }
# endregion


# region :: target - common
# ---------------------------------------------------------
target "common" {
  # Build attestations describe how an image was built, and what it contains.
  # The attestations are created at build-time by BuildKit, and become attached to the final image as metadata.
  #
  # https://docs.docker.com/build/bake/reference/#targetattest
  # https://docs.docker.com/build/metadata/attestations/
  attest = [
    "type=provenance,mode=min",
    "type=sbom"
  ]

  platforms = ["linux/amd64", "linux/arm64"]

  output = [
      "type=registry"
  ]
}
# endregion

# group "components" {
#   targets = ["clarinet"]
# }

# region :: components
# endregion

# region :: devnet
group "devnet" {
  targets = ["stacks"]
}

target "stacks" {
    inherits = ["common"]
    context  = "."
    dockerfile = "dockerfiles/devnet/Stacks.dockerfile"

    contexts = {}
    
    args = {
        # https://github.com/stacks-network/stacks-core/commit/2a74b192f4fed72a21df57f713c3f62e7534de24
        GIT_COMMIT = "2a74b192f4fed72a21df57f713c3f62e7534de24"
    }

    # TODO paramterized labels, refs, and tags

    labels = {
        "org.opencontainers.image.source" = "https://github.com/peterkc/clarinet.git"
    }

    tags = [
        "peterkc/hiro:stacks-latest"
    ]  

    cache-from = [
        "type=registry,ref=peterkc/hiro:stacks-cache-latest"
    ]
    cache-to = [
        "type=registry,ref=peterkc/hiro:stacks-cache-latest,mode=max"
    ]
}



# endregion

