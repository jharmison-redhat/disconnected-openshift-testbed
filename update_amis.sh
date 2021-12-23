#!/bin/bash

version=${1:-8}
regions=${2:-us-east-1,us-east-2,us-west-1,us-west-2,ca-central-1,ap-southeast-2,eu-west-2}
arch=${3:-x86_64}
beta=${4:-false}
style=${5:-Access2}

print_usage() {
    echo "$0 [VERSION [REGIONS [ARCH [BETA [STYLE]]]]]"
}

case $beta in
    false)
        jq_query='map({uploaded: .[0], name: .[1], id: .[2]})|map(select(.name|match("RHEL.*_HVM-.*'"$arch"'.*'"$style"'.*GP2")))|last|.id'
        ;;
    true)
        jq_query='map({uploaded: .[0], name: .[1], id: .[2]})|map(select(.name|match("RHEL.*'"$arch"'.*'"$style"'.*GP2")))|last|.id'
        ;;
    *)
        echo "Invalid option for beta acceptance: $beta" >&2
        print_usage >&2
        exit 1
esac

ami_id() {
    region=${1:-us-east-1}
    aws ec2 describe-images \
        --owners 309956199498 \
        --query 'sort_by(Images, &CreationDate)[*].[CreationDate,Name,ImageId]' \
        --filters "Name=name,Values=RHEL-${version}*" \
        --region $region \
        --output json | \
    jq -r "$jq_query"
}

cp variables.tf variables.tf.old

for region in $(echo "$regions" | tr ',' ' '); do
    region_ami_id=$(ami_id $region)
    echo "Updating $region ami-id to $region_ami_id"
    sed -i "s/$region = \"[^\"]*/$region = \"$region_ami_id/" variables.tf
done

diff variables.tf variables.tf.old
