import { app } from "./app";
import { env } from "./config/env";
import { db, checkDatabase } from "./config/db";
import { logger } from "./config/logger";
async function main(){await checkDatabase();const server=app.listen(env.PORT,()=>logger.info({port:env.PORT},"empresa-service started"));const shutdown=async(signal:string)=>{logger.info({signal},"shutdown requested");server.close(async()=>{await db.end();process.exit(0);});};process.on("SIGINT",()=>void shutdown("SIGINT"));process.on("SIGTERM",()=>void shutdown("SIGTERM"));}
main().catch(err=>{logger.fatal({err},"failed to start");process.exit(1);});
