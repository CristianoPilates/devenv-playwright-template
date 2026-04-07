import { defineConfig, devices } from "@playwright/test";

export default defineConfig({
  testDir: "./tests",
  use: {
    ...devices["Desktop Chrome"],
    headless: false,
    launchOptions: process.env.PLAYWRIGHT_LAUNCH_OPTIONS_EXECUTABLE_PATH
      ? {
          executablePath: process.env.PLAYWRIGHT_LAUNCH_OPTIONS_EXECUTABLE_PATH,
        }
      : undefined,
  },
});
