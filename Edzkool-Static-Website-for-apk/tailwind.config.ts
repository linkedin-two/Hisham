import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./components/**/*.{js,ts,jsx,tsx,mdx}",
    "./app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      colors: {
        navy: {
          DEFAULT: "#0B2A5B",
          dark: "#071D3F",
          light: "#14376E",
        },
        royal: {
          DEFAULT: "#144787",
          hover: "#0E3566",
          light: "#1D5BAA",
        },
        amber: {
          DEFAULT: "#FD9202",
          light: "#FFB84D",
          soft: "#FFD08A",
          dark: "#A85B00",
          tint: "#FFF1DB",
        },
        ice: "#F4F8FE",
        cream: "#FFF8EC",
        "warm-border": "#F3E3C8",
        "cool-border": "#E3EAF4",
        "brand-text": "#1B2A44",
        "brand-muted": "#44546F",
        "brand-subtle": "#9DB4D8",
      },
      fontFamily: {
        sans: ["'Plus Jakarta Sans'", "system-ui", "-apple-system", "sans-serif"],
        serif: ["'Fraunces'", "Georgia", "serif"],
      },
      borderRadius: {
        pill: "9999px",
        "2xl": "22px",
        "3xl": "32px",
      },
      maxWidth: {
        container: "1200px",
      },
    },
  },
  plugins: [],
};
export default config;
