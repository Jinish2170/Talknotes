import express from "express";
import cors from "cors";
import morgan from "morgan";
import fileUpload from "express-fileupload";

// Verify environment variables silently
const envCheck = {
    NODE_ENV: process.env.NODE_ENV,
    CLOUDINARY_CONFIG: {
        cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
        api_key: process.env.CLOUDINARY_API_KEY ? "present" : "missing",
        api_secret: process.env.CLOUDINARY_API_SECRET ? "present" : "missing"
    }
};

// Only log if there's a missing configuration
if (!process.env.CLOUDINARY_CLOUD_NAME || !process.env.CLOUDINARY_API_KEY || !process.env.CLOUDINARY_API_SECRET) {
    console.error("Missing required Cloudinary configuration:", envCheck.CLOUDINARY_CONFIG);
}

import indexRoute from "../routes/index.routes.js";
import bodyParser from "body-parser";
import constants from "../constants/index.js";

const app = express();

app.use(fileUpload({
    useTempFiles: true,
    tempFileDir: './tmp/',
    createParentPath: true,
    debug: false, // Disable debug logging
    limits: { fileSize: 50 * 1024 * 1024 } // 50MB max file size
}));

app.use(bodyParser.json());

app.use(bodyParser.urlencoded({extended: true}))

app.use((req, res, next) => {
  const origin = req.get("origin");

  res.header("Access-Control-Allow-Origin", origin);
  res.header("Access-Control-Allow-Credentials", "true");
  res.header(
    "Access-Control-Allow-Methods",
    "GET,POST,HEAD,OPTIONS,PUT,PATCH,DELETE"
  );
  res.header(
    "Access-Control-Allow-Headers",
    "Origin, X-Requested-With, Content-Type, Accept, Authorization, Cache-Control, Pragma, Access-Control-Request-Method, Access-Control-Allow-Headers, Access-Control-Request-Headers, X-Timezone"
  );

  if (req.method === "OPTIONS") {
    res.sendStatus(204);
  } else {
    next();
  }
});

const corsOption = {
  origin: [process.env.FRONTEND_BASE_URL],
  methods: "GET,POST,HEAD,OPTIONS,PUT,PATCH,DELETE",
  credentials: true,
};

app.use(cors(corsOption));

// Use Morgan only for errors
app.use(morgan("dev", {
    skip: function (req, res) { return res.statusCode < 400 }
}));

// Router
app.use(constants.APPLICATION.url.basePath, indexRoute);

export default app;
