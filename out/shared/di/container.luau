-- Compiled with roblox-ts v3.0.0
local Scope
local Container
do
	Container = setmetatable({}, {
		__tostring = function()
			return "Container"
		end,
	})
	Container.__index = Container
	function Container.new(...)
		local self = setmetatable({}, Container)
		return self:constructor(...) or self
	end
	function Container:constructor()
		self.bindings = {}
		self.singletons = {}
	end
	function Container:createClassFactory(cls)
		return function(scope)
			return scope:create(cls)
		end
	end
	function Container:bindSingleton(token, factory)
		local _bindings = self.bindings
		local _token = token
		local _arg1 = {
			lifetime = "Singleton",
			factory = factory,
		}
		_bindings[_token] = _arg1
	end
	function Container:bindScoped(token, factory)
		local _bindings = self.bindings
		local _token = token
		local _arg1 = {
			lifetime = "Scoped",
			factory = factory,
		}
		_bindings[_token] = _arg1
	end
	function Container:bindTransient(token, factory)
		local _bindings = self.bindings
		local _token = token
		local _arg1 = {
			lifetime = "Transient",
			factory = factory,
		}
		_bindings[_token] = _arg1
	end
	function Container:createScope()
		return Scope.new(self)
	end
	function Container:_getBinding(token)
		local _bindings = self.bindings
		local _token = token
		return _bindings[_token]
	end
	function Container:_getSingleton(token)
		local _singletons = self.singletons
		local _token = token
		return _singletons[_token]
	end
	function Container:_setSingleton(token, value)
		local _singletons = self.singletons
		local _token = token
		local _value = value
		_singletons[_token] = _value
	end
end
local function isToken(x)
	return x.__brand == "DI_TOKEN"
end
do
	Scope = setmetatable({}, {
		__tostring = function()
			return "Scope"
		end,
	})
	Scope.__index = Scope
	function Scope.new(...)
		local self = setmetatable({}, Scope)
		return self:constructor(...) or self
	end
	function Scope:constructor(root)
		self.root = root
		self.scoped = {}
	end
	function Scope:resolve(token)
		local binding = self.root:_getBinding(token)
		if not binding then
			error(`DI: token not bound: {token.name}`)
		end
		if binding.lifetime == "Singleton" then
			local cached = self.root:_getSingleton(token)
			if cached ~= nil then
				return cached
			end
			local created = binding.factory(self)
			self.root:_setSingleton(token, created)
			return created
		end
		if binding.lifetime == "Scoped" then
			local _scoped = self.scoped
			local _token = token
			local cached = _scoped[_token]
			if cached ~= nil then
				return cached
			end
			local created = binding.factory(self)
			local _scoped_1 = self.scoped
			local _token_1 = token
			_scoped_1[_token_1] = created
			return created
		end
		return binding.factory(self)
	end
	function Scope:resolveScope(registryScope)
		local out = {}
		local dst = out
		for k, v in pairs(registryScope) do
			if isToken(v) then
				dst[k] = self:resolve(v)
			elseif typeof(v) == "table" then
				dst[k] = self:resolveScope(v)
			else
				dst[k] = v
			end
		end
		return out
	end
	function Scope:create(Class, manualArg)
		local inject = Class.Inject or {}
		-- ▼ ReadonlyArray.map ▼
		local _newValue = table.create(#inject)
		local _callback = function(t)
			return self:resolve(t)
		end
		for _k, _v in inject do
			_newValue[_k] = _callback(_v, _k - 1, inject)
		end
		-- ▲ ReadonlyArray.map ▲
		local deps = _newValue
		local Ctor = Class
		if manualArg == nil then
			return Ctor.new(unpack(deps))
		end
		return Ctor.new(manualArg, unpack(deps))
	end
end
return {
	Container = Container,
	Scope = Scope,
}
