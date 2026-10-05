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
        bright: {
          purple: "#103C82", // Deep Blue Primary
          "purple-dark": "#0B2A5D",
          violet: "#F58220", // Orange Secondary
          yellow: "#F58220",
          orange: "#F58220",
          "orange-dark": "#D96C0D",
          red: "#FD4343",
          teal: "#00E2A3",
          blue: "#103C82",
          pink: "#E958B7",
          bg: "#F0F4FA",
          dark: "#1E293B",
          muted: "#64748B",
        },
        edzkool: {
          blue: "#103C82",
          "blue-dark": "#0B2A5D",
          orange: "#F58220",
          "orange-dark": "#D96C0D",
          bg: "#F0F4FA",
        }
      },
      fontFamily: {
        sans: ["var(--font-nunito)", "sans-serif"],
        heading: ["var(--font-nunito)", "sans-serif"],
      },
      borderRadius: {
        card: "20px",
        pill: "9999px",
        "3xl": "24px",
      },
      boxShadow: {
        bright: "0 10px 30px -5px rgba(16, 60, 130, 0.1)",
        "bright-hover": "0 20px 40px -10px rgba(16, 60, 130, 0.2)",
        "card-soft": "0 4px 20px 0 rgba(0, 0, 0, 0.05)",
      },
    },
  },
  plugins: [],
};
export default config;
