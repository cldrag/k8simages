FROM golang:1.8 as builder
WORKDIR /go/src/github.com/nailgun/k8s-hostpath-provisioner/
RUN go get -d -v golang.org/x/net/html  
#COPY . .
RUN  wget https://raw.githubusercontent.com/cldrag/k8simages/master/k8s-hostpath-provisioner/.dockerignore && \
     wget https://raw.githubusercontent.com/cldrag/k8simages/master/k8s-hostpath-provisioner/.gitignore && \
     wget https://raw.githubusercontent.com/cldrag/k8simages/master/k8s-hostpath-provisioner/Dockerfile && \
     wget https://raw.githubusercontent.com/cldrag/k8simages/master/k8s-hostpath-provisioner/Dockerfile.scratch && \
     wget https://raw.githubusercontent.com/cldrag/k8simages/master/k8s-hostpath-provisioner/glide.lock && \
     wget https://raw.githubusercontent.com/cldrag/k8simages/master/k8s-hostpath-provisioner/glide.yaml && \
     wget https://raw.githubusercontent.com/cldrag/k8simages/master/k8s-hostpath-provisioner/hostpath-provisioner.go && \
     wget https://raw.githubusercontent.com/cldrag/k8simages/master/k8s-hostpath-provisioner/LICENSE   && \
     wget https://raw.githubusercontent.com/cldrag/k8simages/master/k8s-hostpath-provisioner/Makefile   && \
     wget https://raw.githubusercontent.com/cldrag/k8simages/master/k8s-hostpath-provisioner/README.md && \
     curl https://glide.sh/get | sh && \
     wget -qO- https://get.docker.com/ | sh
RUN make hostpath-provisioner

FROM scratch
COPY --from=builder /go/src/github.com/nailgun/k8s-hostpath-provisioner/hostpath-provisioner /
ENTRYPOINT ["/hostpath-provisioner"]
