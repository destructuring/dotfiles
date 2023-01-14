analytics_settings(False)

load("ext://uibutton", "cmd_button", "location")

for app in ["nomad-48530", "brie", "wh", "so", "the", "defn", "defn-dev-demo"]:
    cmd_button(
        name="deploy-%s" % (app,),
        text="%s" % (app,),
        icon_name="login",
        argv=[
            "bash", "-c",
            """
                set -efu
                eval "$(direnv hook bash)"
                _direnv_hook
                %s
                echo done: %s
            """ % (app,app),
        ],
        resource='proxy-docker'
    )

# idling
local_resource("idle",
    serve_cmd=[
        "bash", "-c",
        """
            sleep infinity
        """
    ]
)
