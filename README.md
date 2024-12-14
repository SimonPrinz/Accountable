# Accountable

> A web app to track your spending, analyze it and plan your riches.
<!-- temporary idea, let's see where we are going with this project -->

## Deploying to production

**This application is under heavy development!**  
**Please use the provided configuration at your own risk.**

## Starting with the development

```bash
# build the docker image and setup with demo data
make setup
```

### Development Links

* **App**: http://localhost:9600
  * *Profiler*: http://localhost:9600/?SPX_KEY=dev&SPX_UI_URI=/  
    see details for profiling [here](#profiling)
* **Database**: MySQL via localhost on port 9601 (root:toor)
* **Redis Insight**: http://localhost:9602 (database at cache:6379)
* **Mailhog**: http://localhost:9603
* **RabbitMQ**: http://localhost:9604 (admin:admin)
* **MinIO Console**: http://localhost:9605 (root:toorToor)

### Useful make targets

* `setup` Builds the docker image and sets the development environment up
* `start` Starts the development environment
* `stop` Stops the development environment
* `restart` Does the same as `stop` and `start`
* `clean` Stops the development environment, removes all containers and images, and removes npm/composer dependencies.


* `composer-test` Runs all composer tests
* `composer-phpstan` Runs PHPStan analysis


* `npm-build` Build webpacks assets in `assets/` with Encore
* `npm-watch` Does the same as `npm-build`, but watches for files changes and recompiles them


* `exec` Drops you in a bash in the app container
* `cache-clear` Clears all caches of the app
* `rebuild` Builds the docker image without any caches (including a fresh pull)

### Debugging

Add a new Server in the *PHP* -> *Servers* settings in PhpStorm with the following details:
- Name: `Accountable`
- Host/Port: `localhost:9600`
- Use path mappings: ✅
- Add a mapping for where repository's root is located to: `/app`

### Profiling

Open the SPX UI (see [development links](#development-links)) and check the `Enabled` box.

To profile a request, make the request you want to profile and reload the SPX UI.
It should appear at the bottom of the list. 

To profile a CLI command run it with the env var `SPX_ENABLED=1` and the results will be displayed after the commands exits.
If you also add `SPX_FP_LIVE=1`, the live refresh will be enabled.

## License

This software is licensed under the MIT License.  
To read the entire license click [here](LICENSE).
