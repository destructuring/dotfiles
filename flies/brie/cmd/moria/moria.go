package main

import (
	"fmt"
	"net/http"

	"github.com/labstack/echo/v4"
)

func replay(e *echo.Echo, app string) {
	replay_path(e, app, fmt.Sprintf("/%s/*", app))
}

func replay_path(e *echo.Echo, app string, path string) {
	send_replay := func(c echo.Context) error {
		c.Response().Header().Set("fly-replay", fmt.Sprintf("app=%s", app))
		return c.NoContent(http.StatusConflict)
	}

	e.GET(path, send_replay)
	e.POST(path, send_replay)
}

func main() {
	e := echo.New()

	replay(e, "defn")
	replay(e, "defn-dev-demo")

	e.Logger.Fatal(e.Start(":8001"))
}
