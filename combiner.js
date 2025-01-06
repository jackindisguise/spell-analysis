const fs = require("fs/promises");
const path = require("path");

async function check(dir, rule, files, ignored) {
  let accumulatedFiles = files || [];
  let searchFiles = await fs.readdir(dir);
  for (let file of searchFiles) {
    let completePath = path.join(dir, file);
    if (ignored && (ignored.includes(completePath) || ignored.includes(file)))
      continue;
    const ext = path.extname(file);
    if ((await fs.lstat(completePath)).isDirectory())
      check(completePath, rule, accumulatedFiles, ignored);
    else if (rule(completePath)) accumulatedFiles.push(completePath);
  }

  return accumulatedFiles;
}

(async () => {
  let result = await check(
    ".",
    (file) => file.indexOf(".d.lua") == -1 && path.extname(file) === ".lua",
    undefined,
    [".git", "index.lua", "combined.lua", "wow-api-type-definitions"]
  );

  result.sort();
  result.unshift("index.lua");
  console.log(result);

  // combine
  const data = [];
  for (let file of result) {
    const fdata = await fs.readFile(file, "utf8");
    if (file === "index.lua") data.push(fdata);
    else
      data.push(`
---[[
--- taken from ${file}
---]]
(function()
${fdata}
end)();`);
  }
  fs.writeFile("combined.lua", data.join("\r\n\r\n"));
})();
