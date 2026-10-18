local ok, incline = pcall(require, 'incline')

local severity_levels = {
  {
    icon = "",
    severity = vim.diagnostic and vim.diagnostic.severity.ERROR,
    group = "DiagnosticError"
  },
  {
    icon = "",
    severity = vim.diagnostic and vim.diagnostic.severity.WARN,
    group = "DiagnosticWarn"
  },
  {
    icon = "",
    severity = vim.diagnostic and vim.diagnostic.severity.INFO,
    group = "DiagnosticInfo"
  },
  {
    icon = "",
    severity = vim.diagnostic and vim.diagnostic.severity.HINT,
    group = "DiagnosticHint"
  }
}

local git_symbols = {
  { key = "added", icon = "", group = "DiffAdd" },
  { key = "changed", icon = "", group = "DiffChange" },
  { key = "removed", icon = "", group = "DiffDelete" }
}

local function get_diagnostic_segments(buf)
  if not vim.diagnostic then
    return {}
  end

  local segments = {}
  for _, item in ipairs(severity_levels) do
    if item.severity then
      local count = #vim.diagnostic.get(buf, { severity = item.severity })
      if count > 0 then
        if #segments > 0 then
          table.insert(segments, { "  " })
        end
        table.insert(segments, { string.format("%s %d", item.icon, count), group = item.group })
      end
    end
  end
  return segments
end

local function get_git_segments(buf)
  local status = vim.b[buf].gitsigns_status_dict
  if not status then
    return {}
  end

  local segments = {}
  for _, item in ipairs(git_symbols) do
    local count = status[item.key]
    if count and count > 0 then
      if #segments > 0 then
        table.insert(segments, { "  " })
      end
      local hl = vim.api.nvim_get_hl(0, { name = item.group })
      local fg_color = hl.fg and string.format("#%06x", hl.fg) or nil
      table.insert(segments, { string.format("%s %d", item.icon, count), guifg = fg_color })
    end
  end
  return segments
end

local function get_highest_severity(buf)
  if not vim.diagnostic then
    return nil
  end

  for _, item in ipairs(severity_levels) do
    if item.severity then
      local count = #vim.diagnostic.get(buf, { severity = item.severity })
      if count > 0 then
        return item.group
      end
    end
  end
  return nil
end

local section_separator = { " │ ", group = "Comment" }

local function join_sections(sections)
  local parts = {}
  for _, section in ipairs(sections) do
    if #section > 0 then
      if #parts > 0 then
        table.insert(parts, section_separator)
      end
      vim.list_extend(parts, section)
    end
  end
  return parts
end

if ok then
 incline.setup {
  debounce_threshold = {
    falling = 50,
    rising = 10
  },
  hide = {
    cursorline = "smart",
    focused_win = false,
    only_win = false
  },
  highlight = {
    groups = {
      InclineNormal = {
        default = true,
        group = "NormalFloat"
      },
      InclineNormalNC = {
        default = true,
        group = "NormalFloat"
      }
    }
  },
  ignore = {
    buftypes = "special",
    filetypes = {},
    floating_wins = true,
    unlisted_buffers = true,
    wintypes = "special"
  },
  render = function(props)
    local sections = {}
    table.insert(sections, get_diagnostic_segments(props.buf))
    table.insert(sections, get_git_segments(props.buf))

    local filename = vim.api.nvim_buf_get_name(props.buf)
    if filename == "" then
      filename = "[No Name]"
    else
      filename = vim.fn.fnamemodify(filename, ":.")
    end

    local highest_severity = get_highest_severity(props.buf)
    local filename_segment = {
      filename,
      gui = props.focused and "bold" or "none"
    }
    if highest_severity then
      filename_segment.group = highest_severity
    end
    table.insert(sections, { filename_segment })

    return join_sections(sections)
  end,
  window = {
    margin = {
      horizontal = 1,
      vertical = 1
    },
    options = {
      signcolumn = "no",
      wrap = false
    },
    overlap = {
      borders = true,
      statusline = false,
      tabline = false,
      winbar = false
    },
    padding = 1,
    padding_char = " ",
    placement = {
      horizontal = "right",
      vertical = "bottom"
    },
    width = "fit",
    winhighlight = {
      active = {
        EndOfBuffer = "None",
        Normal = "InclineNormal",
        Search = "None"
      },
      inactive = {
        EndOfBuffer = "None",
        Normal = "InclineNormalNC",
        Search = "None"
      }
    },
    zindex = 50
  }
 }
end
