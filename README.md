# Samsaadhanii

This is a docker image of [Samsaadhanii](http://scl.samsaadhanii.in/scl/) -- a Sanskrit computational toolkit developed by the Department of Sanskrit Studies, University of Hyderabad.

## How to use?

1. Run the following command in your terminal to start the app. If the image is not already downloaded, it might take some time to download it.

    ```sh
    docker run --rm -it -p 80:80 vipranarayan14/samsaadhanii
    ```
2. Open http://localhost/scl/ in your browser to use the app.
3. Press `Ctrl+C` in your terminal to stop the app.

### Run in background 

To start the app in the background, run the following command in your terminal:

```sh
docker run --rm -d -p 80:80 --name samsaadhanii vipranarayan14/samsaadhanii
```
To stop the app running in background, use the following command:

```sh
docker stop samsaadhanii
```

## Troubleshoot

```
Error starting userland proxy: ... bind: address already in use.
```
If you get the above error while running the container (`docker run ...`), try using a different host port, say, 3000:

```
docker run --rm -it -p 3000:80 vipranarayan14/samsaadhanii
```