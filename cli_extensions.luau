local promise = require("@antiraid/promise")

--- None -> No waiting. If you do a task.delay, you may need to explicitly do a task.wait to allow for the task to execute after delay.
--- WaitAfterExecution -> Wait for all tasks to finish after each execution (if required)
--- YieldBeforePrompt -> Tokio yield before prompting for the next line. Does not apply to InlineScript.
export type ReplTaskWaitMode = "None" | "WaitAfterExecution" | "YieldBeforePrompt"

export type CliEntrypointAction = {
    Repl: {
        task_wait_mode: ReplTaskWaitMode,
    }
} | {
    RunScripts: {
        scripts: {string}
    }
} | {
    InlineScript: {
        script: string,
        task_wait_mode: ReplTaskWaitMode,
    }
}

--[[
#[derive(serde::Serialize, serde::Deserialize)]
pub struct Colorize {
    fg_color: Option<String>,
    bg_color: Option<String>,
    bold: Option<bool>,
    dimmed: Option<bool>,
}
]]--

export type Colorize = {
    fg_color: string?,
    bg_color: string?,
    bold: boolean?,
    dimmed: boolean?,
}

export type CliExtensionsTable = {
    exp: {
        [string]: (...any) -> any
    },
    ext: {
        --- Accepts input from the user on a separate thread (so other lua threads may still run even while waiting for input)
        --- @param prompt The prompt to display to the user
        --- @return A promise that resolves with the user's input
        input: (prompt: string | number) -> promise.LuaPromise<string>,
        --- Requests the CLI to change entrypoint to the provided entrypoint once the script returns
        ---
        --- Useful for plugins that want to provide the user with a REPL after setting up the plugin in _G.
        request_next_entrypoint: (CliEntrypointAction) -> (),
        --- Color print to the console
        ---
        --- Data can either be a string or a Colorize object
        --- If data is a string, it can be prefixed with fg: or bg: for foreground and background colors respectively
        --- or can be "bold" or "dimmed" for bold and dimmed text respectively. More complex use cases should just 
        --- use the Colorize object though
        color_print: (data: string | Colorize, text: string) -> ()
    },
}

local function acquireCliTable(): CliExtensionsTable
    return (_G.cli :: CliExtensionsTable) or error("Invalid execution environment: This script must be run using khronos-cli")
end

return acquireCliTable