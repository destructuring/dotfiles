analytics_settings(False)
allow_k8s_contexts("pod")

load("ext://uibutton", "cmd_button", "location")
load("ext://restart_process", "custom_build_with_restart")

for a in ["on", "off"]:
    cmd_button(
        name="kuma-tp-{}".format(a),
        text="Kuma Transparency: {}".format(a),
        icon_name="login",
        argv=[
            "bash", "-c",
            """
                ~/bin/e kuma-tp-{}
            """.format(a),
        ],
        location=location.NAV,
    )

    cmd_button(
        name="kuma-test",
        text="Kuma Test",
        icon_name="login",
        argv=[
            "bash", "-c",
            """
                seq 1 10 | runmany 6 'curl -sSL whoami.mesh' | grep Hostname | sort | uniq -c
            """.format(a),
        ],
        location=location.NAV,
    )

local_resource("kuma-dp",
    deps=["/home/ubuntu/etc/dev-tp.yaml"],
    serve_cmd=[
        "bash", "-c",
        """
            ~/bin/e kuma-tp-off
            while true; do
                sudo pkill -9 kuma-dp
                ~/bin/e kuma-tp-on
                ~/bin/e kuma-dp-on ~/etc/dev-tp.yaml
                ~/bin/e kuma-tp-off
            done
        """
    ]
)
