# syntax=docker/dockerfile:1.4

FROM node:18-alpine as install
RUN corepack enable \
    && corepack prepare yarn@stable --activate \
    && yarn -v
WORKDIR /app
COPY package.json .
COPY yarn.lock .
COPY .yarnrc.yml .
COPY .yarn .yarn
RUN --mount=type=cache,target=/root/.yarn/berry/cache,rw \
    yarn -v && yarn config get cacheFolder \
    && yarn install

FROM install as build
WORKDIR /app
COPY . ./
RUN --mount=type=cache,target=/root/.yarn/berry/cache,rw \
    yarn build

FROM nginx:alpine
COPY --from=build /app/build /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
