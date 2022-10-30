analytics_settings(False)
allow_k8s_contexts("k3d-control")

load("ext://uibutton", "cmd_button", "location")
load("ext://restart_process", "custom_build_with_restart")

cmd_button(
    name="check",
    text="Check",
    icon_name="login",
    argv=[
        "bash", "-c",
        """
            make check
        """,
    ],
    location=location.NAV,
)

cmd_button(
    name="client",
    text="Client",
    icon_name="login",
    argv=[
        "bash", "-c",
        """
            dist/cmd.client/bin
        """,
    ],
    location=location.NAV,
)

local_resource("kuma-dp",
    deps=["/home/ubuntu/etc/dev-tp.yaml"],
    serve_cmd=[
        "bash", "-c",
        """
            set -x;
            ~/bin/e kuma-tp-off
            while true; do
                ~/bin/e kuma-tp-on
                ~/bin/e kuma-dp-on ~/etc/dev-tp.yaml
                ~/bin/e kuma-tp-off
                sudo pkill -9 -f "kuma-dp run --dataplane-token-file=/tmp/dev-toke[n]"
                sleep 10
            done
        """
    ]
)

local_resource("kuma-cp",
    serve_cmd=[
        "bash", "-c",
        """
            set -x;
            while true; do
                ~/bin/e kuma-cp-on
                sudo pkill -9 -f "kuma-cp ru[n]"
                sleep 10
            done
        """
    ]
)

#local_resource("kuma-ingress",
#    deps=["/home/ubuntu/etc/ingress-dp.yaml"],
#    serve_cmd=[
#        "bash", "-c",
#        """
#            set -x
#            while true; do
#                ~/bin/e kuma-ingress-on || true
#                sudo pkill -9 -f "kuma-dp run --dataplane-token-file=/tmp/ingress-toke[n]" || true
#                sleep 1
#            done
#        """
#    ]
#)

local_resource("temporal",
    serve_cmd=[
        "bash", "-c",
        """
            set -x;
            while true; do
                pkill -9 temporalite
                temporalite start --namespace default
            done
        """
    ]
)
