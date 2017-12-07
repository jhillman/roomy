package ${packageName}.model
 
import com.google.gson.Gson
import com.google.gson.TypeAdapterFactory
import com.google.gson.TypeAdapter
import com.google.gson.reflect.TypeToken
 
object ModelAdapterFactory {
    @Suppress("UNCHECKED_CAST")
    fun create(): TypeAdapterFactory {
        return object : TypeAdapterFactory {
            override fun <T> create(gson: Gson, type: TypeToken<T>): TypeAdapter<T>? {
                val rawType = type.rawType as Class<T>

                when {
<#list gsonModels as model>
                    ${packageName}.model.${model.package}.${model.name}::class.java.isAssignableFrom(rawType) -> return ${packageName}.model.${model.package}.${model.name}.GsonTypeAdapter(gson) as TypeAdapter<T>
</#list>
                    else -> return null
                }
            }
        }
    }
}