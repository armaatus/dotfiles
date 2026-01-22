local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local rep = require("luasnip.extras").rep

return {
	s("rnstory", {
		t("import type { Meta, StoryObj } from '@storybook/react-native';"),
		t({ "", "import " }),
		i(1, "ComponentName"),
		t(" from '@/components/"),
		i(2, "ui"),
		t("/"),
		rep(1),
		t("';"),
		t({ "", "", "const meta = {" }),
		t({ "", "  component: " }),
		rep(1),
		t(","),
		t({ "", "} satisfies Meta<typeof " }),
		rep(1),
		t(">;"),
		t({ "", "", "export default meta;", "" }),
		t({ "", "type Story = StoryObj<typeof meta>;", "" }),
		t({ "", "export const Default: Story = {" }),
		t({ "", "  args: {" }),
		t({ "", "    " }),
		i(3, "title: 'Default'"),
		t({ "", "  }," }),
		t({ "", "};", "" }),
		t({ "", "export const " }),
		i(4, "CustomText"),
		t(": Story = {"),
		t({ "", "  args: {" }),
		t({ "", "    " }),
		i(5, "title: 'Custom'"),
		t({ "", "  }," }),
		t({ "", "};" }),
		i(0),
	}),
}
