#!/usr/bin/env node
import fs from "fs";
import path from "path";
import process from "process";

// G1000 MFD Bottom = "Supplemental Data Card" in Garmin Aviation Database Manager.
// "image" capture image via DD.
// "backup" capture files via tar, optionally compressing.
// "logs" capture logs to CSV or SQLite file.

/* Note: the Node process terminates when the event loop is empty, so this IIFE will run to completion and the exit code
will be 0 unless we explicitly exit with some other value. */
(async () => {
    const {argv} = process;
    const command = path.basename(argv[1]).replace(/\.[^./]+$/, "");
    if (-1 !== argv.indexOf("--help") || -1 !== argv.indexOf("-h") || argv.length < 3) {
        console.log(`Usage: ${command} delete <service> <account>`);
        console.log(`       ${command} get <service> <account>`);
        console.log(`       ${command} set <service> <account> <password>`);
    } else if (-1 !== argv.indexOf("--version") || -1 !== argv.indexOf("-v")) {
        let version = "(development build)";
        const mainPath = require.main?.path;
        if (null != mainPath) {
            try {
                version = await fs.promises.readFile(path.resolve(mainPath, "./VERSION"), "utf8");
            } catch (err) {
                /* Ignore. */
            }
        }
        console.log(`${command} ${version}`);
    } else {
        console.log("TODO!")
    }
})();
