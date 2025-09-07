import {JestConfigWithTsJest} from "ts-jest";

const options: JestConfigWithTsJest = {
    preset: "ts-jest",
    testEnvironment: "node",
    moduleDirectories: ["node_modules", "src"],
    moduleNameMapper: {
        "(.*)\\.js$": "$1"
    },
    reporters: [
        "default",
        [
            "jest-junit",
            {
                "outputDirectory": "./build/report",
                "outputName": "test-results.xml"
            }
        ]
    ],
    testMatch: ["**/__tests__/**/*.test.ts"]
};

export default options;
