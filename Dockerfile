# use the official Bun image
# see all versions at https://hub.docker.com/r/oven/bun/tags
FROM node:22.21.1 AS base

WORKDIR /usr/src/app

# install dependencies into temp directory
# this will cache them and speed up future builds
FROM base AS install
RUN mkdir -p /temp/dev
COPY package.json /temp/dev/
RUN cd /temp/dev && yarn install

# install with --production (exclude devDependencies)
RUN mkdir -p /temp/prod
COPY package.json /temp/prod/
RUN cd /temp/prod && yarn install --frozen-lockfile --production

# copy node_modules from temp directory
# then copy all (non-ignored) project files into the image
FROM base AS prerelease
COPY --from=install /temp/dev/node_modules node_modules
COPY --from=install /temp/dev/yarn.lock .
COPY . .

# run the app
ENTRYPOINT [ "yarn", "start:dev" ]

RUN yarn build

# copy production dependencies and source code into final image
FROM node:22.21.1-slim AS production

WORKDIR /usr/src/app

COPY --from=install /temp/prod/node_modules node_modules
COPY --from=prerelease /usr/src/app/dist dist

CMD ["node", "dist/main"]

# test Stage
FROM base AS test
COPY --from=install /temp/dev/node_modules node_modules
COPY --from=install /temp/dev/yarn.lock .
COPY . .

CMD ["yarn", "test:cov"]
