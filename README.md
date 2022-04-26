# Base Image

This repo demonstrates a CI/CD flow for how to keep application images 
up-to-date when their base images are refreshed. It does this via opening
downstream pull requests on repositories that use this image. This flow
typically works within corporates where they have control of both the upstream
and downstream repositories.

## Base Image CI

The CI process of the base image involves triggering a run both nightly
and on pushes to `main`. 

The nightly builds are important to pick up any
change in upstream dependencies which in the case of this example repo is
Microsoft's ASP.Net Core runtime image. The other reason to run nightly
is to pickup any updated Alpine packages that were published. Changes in
either of these upstream dependencies will trigger a new base image to be
published to Github's Container Registry (though the process is extensible
to any CI tool and utilising any Docker registry).

The builds on pushes to `main` are simply to support any modifications to the base
image where PRs are merged to `main` and a new base image needs to be cut

### Publish detection

A mechanism needs to exist to stop needlessly publishing base images where there is
no net change to the image. This is done using Google's `container-diff` tool which
supports various algorithms for comparing two images. The CI process uses this by
building a new image and comparing this to the `latest` published image. If a difference
is detected then this suggests a new image is needed to be published. Currently, this
repo is configured to simply use the `size` algorithm which means any size difference
between the two images will cause a publish to downstream repos using the base image.

### CI Pseudo-code

The rough process for the CI workflow is as follows

#### Build Job

The purpose of the build job is to build and conditionally publish the Docker image

1. Checkout the base image repository
2. Configure Docker Build-X
3. Install Google `container-diff`
4. Login to Container Registry (so we can pull and push images)
5. Build the release candidate Docker image
6. Compare the release candidate to the latest published image using `container-diff`
7. Publish release candidate to container registry and mark as latest
8. Set publish flag output

#### Downstream PR Job

The purpose of the Downstream PR Job(s) is to conditionally open pull requests on
downstream repositories using the base image and request the bump the base image usage
to the latest version

1. Checkout the downstream repository (using a Git token with sufficient privilege)
2. Configure Git user details (for the commit)
3. Create a new PR branch
4. Execute a shell command to replace all usages of the base image within the downstream repo with the latest base image tag (tag here is the git sha but any uniquely generated tag can be used)
5. Add these modified files to git, commit and push to the remote git repository
6. Open a pull request to merge this branch to the default branch of the downstream repository
7. (optional) Merge the pull request automatically

