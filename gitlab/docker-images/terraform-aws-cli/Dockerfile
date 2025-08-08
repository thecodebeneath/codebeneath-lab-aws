FROM hashicorp/terraform:latest AS build

FROM amazon/aws-cli

COPY --from=build /bin/terraform /usr/local/bin/terraform
ENTRYPOINT ["terraform"]
